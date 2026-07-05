-- Generate a flat JSON index of all packages in this repository.
--
-- Output: dist/repology_packages_index.json
-- Consumers: external trackers/aggregators (repology.org and similar) that
-- need a structured view of the repository without parsing xmake.lua files.
-- See xmake-io/xmake-repo#9966.  Run:  xmake l scripts/build_index.lua
--
-- Schema:
--   {
--     "generated_at": "<ISO-8601 UTC>",
--     "count": <N>,
--     "packages": [
--       {
--         "name":           "<package name>",
--         "version":        "<latest version, alias prefix and leading 'v' stripped>",
--         "versions":       ["<all versions, ascending, normalized like version>"],
--         "description":    "<set_description(...)>",
--         "license":        "<set_license(...)>",
--         "homepage":       "<set_homepage(...)>",
--         "repository_url": "<verbatim .git URL from add_urls, normalized forge URL, or homepage fallback>",
--         "download_url":   "<first entry of download_urls>",
--         "download_urls":  ["<all non-.git add_urls(...) entries with $(version) resolved for the latest version>"],
--         "patches":        ["<repo-relative path or URL of patches applied to the latest version>"],
--         "base":           "<base package name, only for set_base(...) alias packages>"
--       }, ...
--     ]
--   }
--
-- Packages that declare neither versions nor urls (system/SDK wrappers like
-- opengl, matlab) are excluded. set_base(...) aliases inherit versions and
-- urls from their base package and carry a "base" field.
--
-- Descriptions can branch on the build host (is_host("windows"),
-- os.arch() == "x64", is_plat("windows"), ...), so a single load only sees
-- the current machine's branch. Every package is therefore re-loaded under
-- each synthetic host/plat/arch profile below and the results merged, making
-- the index identical regardless of the machine that generates it.

import("core.base.json")
import("core.base.semver")
import("core.package.package")

-- Covers every host used with is_host(...) and every arch compared against
-- os.arch() / used with is_arch(...) in package descriptions (zig, mkl, ...).
-- plat/arch go through the official load_from_repository() opt; the same
-- values are applied as host and os.arch() via _install_synthetic_hooks().
local _synthetic_profiles = {}
for _, p in ipairs({{"windows", "x64", "x86", "arm64"},
                    {"macosx", "arm64", "x86_64"},
                    {"linux", "x86_64", "arm64", "i386"},
                    {"bsd", "x86_64"}}) do
    for i = 2, #p do
        table.insert(_synthetic_profiles, {plat = p[1], arch = p[i]})
    end
end

-- The active synthetic profile, empty outside the profile re-load passes.
local _synthetic = {}

-- Match the loader pattern used by scripts/packages.lua and scripts/autoupdate.lua.
function _load_package(packagename, packagedir, packagefile, opt)
    opt = opt or {}
    local funcinfo = debug.getinfo(package.load_from_repository)
    if funcinfo and funcinfo.nparams == 3 then -- >= 2.7.8
        return package.load_from_repository(packagename, packagedir,
            {packagefile = packagefile, plat = opt.plat, arch = opt.arch})
    else
        return package.load_from_repository(packagename, nil, packagedir, packagefile)
    end
end

-- import("core.package.package") returns a sandbox wrapper; the underlying
-- core module (which owns the package interpreter) is only reachable as an
-- upvalue of the wrapped functions. Returns nil on future xmake refactors —
-- callers must degrade gracefully.
function _core_package_module()
    return try {
        function ()
            for i = 1, 16 do
                local name, value = debug.getupvalue(package.load_from_repository, i)
                if not name then
                    break
                end
                if name == "package" and type(value) == "table" and value._interpreter then
                    return value
                end
            end
        end,
        catch { function () end }
    }
end

-- Reroute the description-scope is_host / os.arch / os.host predicates
-- through _synthetic so the profile passes can emulate other build hosts.
-- They live in the interpreter's builtin-module table (_PUBLIC), captured at
-- interpreter creation, so this must run before the first package load.
-- Returns true if the hooks are installed; bails out (false) instead of
-- installing hooks that would only crash later on a future xmake refactor.
function _install_synthetic_hooks(core)
    if not core then
        return false
    end
    return try {
        function ()
            local pub = core._interpreter()._PUBLIC
            local real_is_host = pub.is_host
            local interp_os = pub.os
            local real_arch_func = interp_os and interp_os.arch
            local real_host_func = interp_os and interp_os.host
            if type(real_is_host) ~= "function" or type(real_arch_func) ~= "function"
                or type(real_host_func) ~= "function" then
                return false
            end
            pub.is_host = function (...)
                if _synthetic.host then
                    for _, v in ipairs(table.join(...)) do
                        if v and v == _synthetic.host then
                            return true
                        end
                    end
                    return false
                end
                return real_is_host(...)
            end
            interp_os.arch = function (...)
                return _synthetic.os_arch or real_arch_func(...)
            end
            interp_os.host = function (...)
                return _synthetic.host or real_host_func(...)
            end
            return true
        end,
        catch { function () return false end }
    }
end

-- Drop a package (and its base, for aliases) from the loader cache so it can
-- be re-evaluated under a different synthetic profile.
function _uncache_package(core, packagename, basename)
    local cache = core and core._memcache and core._memcache()
    if cache and cache.set2 then
        cache:set2("packages", packagename, nil)
        if basename then
            cache:set2("packages", basename, nil)
        end
    end
end

-- Resolve set_base("...") like xmake's require impl: load the base package
-- and attach it, so instance:get(...) falls back to it for urls, homepage,
-- ... Recurses for multi-level chains, with a depth guard against cycles.
function _resolve_base(instance, opt, depth)
    depth = depth or 0
    local basename = instance:get("base")
    if not basename or instance:base() or depth > 8 then
        return
    end
    local basedir = path.join("packages", basename:sub(1, 1):lower(), basename:lower())
    local baseinst = _load_package(basename, basedir, path.join(basedir, "xmake.lua"), opt)
    if baseinst then
        _resolve_base(baseinst, opt, depth + 1)
        instance._BASE = baseinst
    end
end

-- Run on_source() like xmake does before an install, so packages that build
-- their url/version lists dynamically (cmake schemes, opencv-mobile) are
-- covered. Best-effort: a script that needs install-time context just leaves
-- the package without versions.
function _init_source(instance)
    try {
        function ()
            -- some on_source scripts read requireinfo().version; give them an
            -- empty requireinfo so they fall through to their static defaults
            instance._REQUIREINFO = instance._REQUIREINFO or {}
            if instance._init_source then
                instance:_init_source()
            end
        end,
        catch { function () end }
    }
end

-- Three-way version comparison for picking "latest". semver.compare()
-- ignores build metadata after "+", but mkl versions conda artifacts as
-- "2025.2.0+627" (win-64) next to "2025.2.0+628" (linux-64) — break semver
-- ties on the build suffix, numerically when possible. Non-semver versions
-- (git refs, ...) compare as plain strings.
function _compare_versions(a, b)
    if semver.is_valid(a) and semver.is_valid(b) then
        local diff = semver.compare(a, b)
        if diff ~= 0 then
            return diff
        end
        a, b = a:match("%+(.*)$") or "", b:match("%+(.*)$") or ""
        local an, bn = tonumber(a), tonumber(b)
        if an and bn then
            a, b = an, bn
        end
    end
    return a == b and 0 or a < b and -1 or 1
end

function _all_versions(instance)
    -- instance:versions() also reads add_versionfiles(...) files (libcurl,
    -- ndk, ...) and strips "alias:" url prefixes.
    local list = table.wrap(instance:versions())
    table.sort(list, function(a, b) return _compare_versions(a, b) < 0 end)
    return list
end

-- Strip a leading "v" tag prefix ("v0.1.30") so the emitted value matches
-- how downstream trackers canonicalize versions; leaves "1.2.10" untouched.
function _normalize_version_for_output(version)
    if type(version) == "string" and version:match("^v%d") then
        return version:sub(2)
    end
    return version
end

function _resolve_url(instance, url, version)
    if not url or not version then
        return nil
    end
    if not url:find("%$%(version%)") and not url:find("%$%(version_nodot%)") then
        return url
    end
    -- A URL declared with `add_urls(tmpl, {version = function (v) ... end})`
    -- carries a per-URL transform applied before substituting $(version) —
    -- matters for "v"-prefixed tags (libthai) and computed path components
    -- (sqlite3).
    local effective = version
    local filter = instance:url_version(url)
    if filter then
        -- xmake passes a semver object; fall back to the raw string for
        -- non-semver versions where semver.new() raises.
        local arg = version
        try {
            function () arg = semver.new(version) end,
            catch { function () end }
        }
        local result = filter(arg or version)
        if result ~= nil then
            effective = tostring(result)
        end
    end
    -- Escape "%" in the replacement so URL templates like "ACE%2BTAO-..."
    -- (tao_idl) aren't interpreted as gsub back-references.
    local resolved = url:gsub("%$%(version%)", (effective:gsub("%%", "%%%%")))
    resolved = resolved:gsub("%$%(version_nodot%)", (effective:gsub("%.", ""):gsub("%%", "%%%%")))
    return resolved
end

-- instance:urls() is scheme-aware: it sees urls added dynamically by
-- on_source() and falls back to the set_base(...) base package. Returns raw
-- templates; $(version) placeholders are resolved against the latest version.
function _urls_list(instance)
    local urls = instance:urls()
    if type(urls) == "string" then
        return {urls}
    end
    return urls or {}
end

-- ".git" / "git://" / "git+..." URLs are repository pointers, not download
-- URLs ("git://" covers GNU Savannah projects without a ".git" suffix).
function _is_git_url(url)
    return type(url) == "string"
        and (url:find("^git%+") or url:find("^git://") or url:find("%.git$")) ~= nil
end

-- Skip git entries: repology wants file URLs in download_urls.
function _download_urls(instance, version)
    local resolved = {}
    local seen = {}
    for _, url in ipairs(_urls_list(instance)) do
        if not _is_git_url(url) then
            local u = _resolve_url(instance, url, version)
            if u and not seen[u] then
                seen[u] = true
                table.insert(resolved, u)
            end
        end
    end
    return resolved
end

-- Forge hosts whose "/archive/", "/releases/", "/get/" path segments are
-- unambiguous version-archive markers (not just a directory name on a
-- tarball mirror like download.imagemagick.org/.../releases/...).
local _forge_hosts = {
    ["github.com"] = true, ["gitlab.com"] = true, ["bitbucket.org"] = true,
    ["codeberg.org"] = true, ["gitea.com"] = true, ["gitee.com"] = true,
}

-- Collapse a download URL to its bare "<scheme>://<host>/<owner>/<repo>"
-- root; nil for URLs that do not match a recognized forge layout (vendor
-- tarball mirrors like ftpmirror.gnu.org do not point at a repository).
function _normalize_repo_url(url)
    if type(url) ~= "string" then
        return nil
    end
    url = url:gsub("^git%+", "")
    -- "/-/archive/" and a bare ".git" suffix are forge-specific on any host
    -- (self-hosted gitlab instances); the other markers only on known hosts.
    local root = url:match("^(https?://[^/]+/[^/]+/[^/]+)/%-/archive/")
        or url:match("^(https?://[^/]+/[^/]+/[^/]+)%.git$")
    if root then
        return root
    end
    local host = url:match("^https?://([^/]+)/")
    if host and _forge_hosts[host] then
        return url:match("^(https?://[^/]+/[^/]+/[^/]+)/archive/")
            or url:match("^(https?://[^/]+/[^/]+/[^/]+)/releases/")
            or url:match("^(https?://[^/]+/[^/]+/[^/]+)/get/")
    end
end

-- Accept a homepage as repository_url only if it is exactly a forge
-- "<owner>/<repo>" root (not github.com/owner/repo/wiki and the like).
function _homepage_as_repo_url(homepage)
    if type(homepage) ~= "string" then
        return nil
    end
    local host, rest = homepage:match("^https?://([^/]+)/(.+)$")
    if not host or not _forge_hosts[host] then
        return nil
    end
    local owner, repo = rest:match("^([^/]+)/([^/]+)/?$")
    if owner and repo then
        return ("https://%s/%s/%s"):format(host, owner, repo)
    end
end

-- Prefer a verbatim git URL declared in add_urls — repology asked for the
-- raw git URL with the ".git" suffix preserved.
function _repository_url(instance, homepage)
    for _, url in ipairs(_urls_list(instance)) do
        if _is_git_url(url) then
            return (url:gsub("^git%+", ""))
        end
    end
    for _, url in ipairs(_urls_list(instance)) do
        local repo = _normalize_repo_url(url)
        if repo then
            return repo
        end
    end
    return _homepage_as_repo_url(homepage)
end

-- Patches applied to the given version, as repo-relative paths (verbatim
-- URLs for remote patches). Mirrors scheme.lua:patches(): exact version key
-- first, then semver range keys like ">=1.0.0". Relative paths resolve
-- against the package scriptdir (falling back to the set_base(...) package),
-- like xmake does when applying patches at install time.
function _patches_for_version(instance, version)
    local patchinfos = instance:get("patches")
    if not patchinfos or not version then
        return nil
    end
    local rootdir = os.curdir()
    local result = {}
    local function _append(patchinfo)
        for idx = 1, #patchinfo, 2 do
            local url = patchinfo[idx]
            if type(url) == "string" then
                if not url:find("^https?://") then
                    if not path.is_absolute(url) then
                        local resolved = path.join(instance:scriptdir(), url)
                        if not os.isfile(resolved) and instance:base() then
                            resolved = path.join(instance:base():scriptdir(), url)
                        end
                        url = resolved
                    end
                    url = path.relative(url, rootdir)
                end
                table.insert(result, (url:gsub("\\", "/")))
            end
        end
    end
    local exact = patchinfos[version]
    if exact then
        _append(table.wrap(exact))
    else
        for range, patchinfo in pairs(patchinfos) do
            try {
                function ()
                    if semver.satisfies(version, range) then
                        _append(table.wrap(patchinfo))
                    end
                end,
                catch { function () end }
            }
        end
    end
    if #result > 0 then
        table.sort(result)
        return result
    end
end

function _entry(instance)
    -- init dynamic sources for the package and its set_base(...) chain; the
    -- accessors below all fall back to the base once _BASE is attached
    _init_source(instance)
    local base = instance:base()
    local depth = 0
    while base and depth < 8 do
        _init_source(base)
        base = base:base()
        depth = depth + 1
    end
    local versions = _all_versions(instance)
    local version = versions[#versions]
    local versions_out
    if #versions > 0 then
        local seen = {}
        versions_out = {}
        for _, v in ipairs(versions) do
            local nv = _normalize_version_for_output(v)
            if not seen[nv] then
                seen[nv] = true
                table.insert(versions_out, nv)
            end
        end
    end
    local homepage = instance:get("homepage")
    local download_urls = _download_urls(instance, version)
    return {
        name           = instance:name(),
        base           = instance:get("base"),
        version        = _normalize_version_for_output(version),
        versions       = versions_out,
        description    = instance:get("description"),
        license        = instance:get("license"),
        homepage       = homepage,
        repository_url = _repository_url(instance, homepage),
        download_url   = download_urls[1],
        download_urls  = #download_urls > 0 and download_urls or nil,
        patches        = _patches_for_version(instance, version),
    }
end

function _load_entry(packagename, packagedir, packagefile, opt)
    local instance = _load_package(packagename, packagedir, packagefile, opt)
    if instance and not instance:is_template() then
        _resolve_base(instance, opt)
        return _entry(instance)
    end
end

-- Merge the per-profile candidates for one package: union of versions;
-- scalar fields from the profile that carries the newest version (so version
-- and download_urls stay consistent); download url mirrors and patches from
-- every profile that agrees on that version; repository_url from any profile
-- (a verbatim git URL — libllvm only declares one on non-windows branches —
-- wins over normalized forge/homepage fallbacks, in profile order).
function _merge_candidates(candidates)
    local best
    for _, candidate in ipairs(candidates) do
        if candidate.version and (not best or _compare_versions(candidate.version, best.version) > 0) then
            best = candidate
        end
    end
    if not best then
        return nil
    end
    local versions, seen = {}, {}
    local urls, seen_urls = {}, {}
    local patches, seen_patches = {}, {}
    for _, candidate in ipairs(candidates) do
        for _, v in ipairs(candidate.versions or {}) do
            if not seen[v] then
                seen[v] = true
                table.insert(versions, v)
            end
        end
        if candidate.version == best.version then
            for _, u in ipairs(candidate.download_urls or {}) do
                if not seen_urls[u] then
                    seen_urls[u] = true
                    table.insert(urls, u)
                end
            end
            for _, p in ipairs(candidate.patches or {}) do
                if not seen_patches[p] then
                    seen_patches[p] = true
                    table.insert(patches, p)
                end
            end
        end
    end
    local repo
    for _, candidate in ipairs(candidates) do
        local r = candidate.repository_url
        if r and (r:find("%.git$") or r:find("^git://")) then
            repo = r
            break
        end
        repo = repo or r
    end
    table.sort(versions, function(a, b) return _compare_versions(a, b) < 0 end)
    best.versions = versions
    best.repository_url = repo
    if #urls > 0 then
        best.download_urls = urls
        best.download_url = urls[1]
    end
    if #patches > 0 then
        table.sort(patches)
        best.patches = patches
    end
    return best
end

function main()
    local core = _core_package_module()
    local hooks_ok = _install_synthetic_hooks(core)

    local entries = {}
    local no_version = {}
    local skipped = {}
    for _, packagedir in ipairs(os.dirs(path.join("packages", "*", "*"))) do
        local packagename = path.filename(packagedir)
        local packagefile = path.join(packagedir, "xmake.lua")
        -- Isolate per-package failures: a broken filter in one xmake.lua must
        -- not abort the whole generator.
        try {
            function ()
                -- The plain load only sees the current machine's conditional
                -- branches (zig on macOS yields macOS-only urls); it provides
                -- the base name and a fallback, while the indexed entry is
                -- merged from the per-profile re-loads.
                local entry = _load_entry(packagename, packagedir, packagefile)
                if not entry then
                    return
                end
                local merged
                if hooks_ok then
                    local candidates = {}
                    for _, profile in ipairs(_synthetic_profiles) do
                        try {
                            function ()
                                _uncache_package(core, packagename, entry.base)
                                _synthetic.host = profile.plat
                                _synthetic.os_arch = profile.arch
                                local candidate = _load_entry(packagename, packagedir, packagefile,
                                    {plat = profile.plat, arch = profile.arch})
                                if candidate and candidate.version then
                                    table.insert(candidates, candidate)
                                end
                            end,
                            catch { function () end }
                        }
                        _synthetic.host = nil
                        _synthetic.os_arch = nil
                    end
                    _uncache_package(core, packagename, entry.base)
                    merged = _merge_candidates(candidates)
                end
                -- fallback: profile emulation unavailable, or it missed this
                -- package's conditionals (an exotic host/arch branch)
                if not merged and entry.version then
                    merged = entry
                end
                if merged then
                    table.insert(entries, merged)
                else
                    table.insert(no_version, packagename)
                end
            end,
            catch {
                function (errors)
                    table.insert(skipped, {name = packagename, error = tostring(errors)})
                end
            }
        }
    end

    table.sort(entries, function(a, b) return a.name < b.name end)

    os.mkdir("dist")
    local outpath = path.join("dist", "repology_packages_index.json")
    json.savefile(outpath, {
        generated_at = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        count        = #entries,
        packages     = entries,
    })
    cprint("${green}wrote${clear} %s (%d packages)", outpath, #entries)
    if not hooks_ok then
        cprint("${yellow}warning${clear}: synthetic host/arch hooks unavailable, host-conditional versions may be missing")
    end
    if #no_version > 0 then
        cprint("${yellow}excluded${clear} %d package(s) without resolvable upstream versions (system/SDK wrappers):", #no_version)
        cprint("  %s", table.concat(no_version, " "))
    end
    if #skipped > 0 then
        cprint("${yellow}skipped${clear} %d package(s):", #skipped)
        for _, s in ipairs(skipped) do
            cprint("  %s: %s", s.name, s.error)
        end
    end
end
