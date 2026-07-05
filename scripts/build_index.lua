-- Generate a flat JSON index of all packages in this repository.
--
-- Output: dist/repology_packages_index.json
--
-- Intended consumers: external trackers/aggregators (repology.org and
-- similar) that need a structured, declarative view of the repository
-- without parsing xmake.lua source files. See xmake-io/xmake-repo#9966.
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
--       },
--       ...
--     ]
--   }
--
-- Packages that declare neither versions nor urls (pure system/SDK wrappers
-- like opengl, matlab, autotools) are excluded: there is no upstream release
-- to report. Alias packages created with set_base(...) inherit versions and
-- urls from their base package and carry a "base" field.
--
-- Some packages only declare versions for a non-linux build host
-- (is_host("windows"), os.arch() == "x64", is_plat("windows"), ...). Those
-- are re-loaded under a set of synthetic host/plat/arch profiles and the
-- results merged, so the index is complete regardless of the machine that
-- generates it. See _synthetic_profiles below.
--
-- Run:  xmake l scripts/build_index.lua

import("core.base.json")
import("core.base.semver")
import("core.package.package")

-- Synthetic profiles used to re-load packages whose versions are declared
-- behind host/plat/arch conditionals. plat/arch go through the official
-- load_from_repository() opt (backed by is_plat/is_arch); host and os_arch
-- are applied via the hooks installed by _install_synthetic_hooks().
local _synthetic_profiles = {
    {name = "windows-x64",   plat = "windows", arch = "x64",    host = "windows", os_arch = "x64"},
    {name = "windows-x86",   plat = "windows", arch = "x86",    host = "windows", os_arch = "x86"},
    {name = "macosx-arm64",  plat = "macosx",  arch = "arm64",  host = "macosx",  os_arch = "arm64"},
    {name = "macosx-x86_64", plat = "macosx",  arch = "x86_64", host = "macosx",  os_arch = "x86_64"},
    {name = "linux-x86_64",  plat = "linux",   arch = "x86_64", host = "linux",   os_arch = "x86_64"},
}

-- The active synthetic profile ({host = ..., os_arch = ...}), empty outside
-- the profile re-load passes.
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
-- core module (which owns the package interpreter and its is_host/is_plat
-- predicates) is only reachable as an upvalue of the wrapped functions.
-- Returns nil on future xmake refactors — callers must degrade gracefully.
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

-- Reroute the description-scope host/arch predicates through _synthetic so
-- the profile passes can emulate other build hosts. Must run before the
-- first package load: the interpreter captures the predicate functions when
-- it is created. Returns true if the hooks are installed.
function _install_synthetic_hooks(core)
    if not core then
        return false
    end
    return try {
        function ()
            -- the description scope gets is_host / os.arch / os.host from the
            -- interpreter's builtin-module table (core/sandbox/modules/interpreter/),
            -- registered into _PUBLIC at interpreter creation — patch them there
            local pub = core._interpreter()._PUBLIC
            local real_is_host = pub.is_host
            -- is_host(...) in package descriptions (cuda, aqt, ndk, appimage, ...)
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
            -- os.arch() / os.host() in package descriptions (w64devkit, aqt, ...)
            local interp_os = pub.os
            local real_arch_func = interp_os.arch
            local real_host_func = interp_os.host
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
    if core then
        core._memcache():set2("packages", packagename, nil)
        if basename then
            core._memcache():set2("packages", basename, nil)
        end
    end
end

-- Resolve set_base("...") the same way xmake's require impl does: load the
-- base package and attach it, so instance:get(...) falls back to the base
-- for urls, homepage, description, license, ...
function _resolve_base(instance, opt)
    local basename = instance:get("base")
    if not basename or instance:base() then
        return
    end
    local basedir = path.join("packages", basename:sub(1, 1):lower(), basename)
    local baseinst = _load_package(basename, basedir, path.join(basedir, "xmake.lua"), opt)
    if baseinst then
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

function _all_versions(instance)
    -- instance:versions() also reads add_versionfiles(...) files (libcurl,
    -- ndk, ...) and strips "alias:" url prefixes; fall back to the raw
    -- versions table on older xmake.
    local list = {}
    if instance.versions then
        list = table.wrap(instance:versions())
    else
        local seen = {}
        for v, _ in pairs(table.wrap(instance:get("versions"))) do
            local key = tostring(v)
            local pos = key:find(":", 1, true)
            if pos then
                key = key:sub(pos + 1)
            end
            if key ~= "" and not seen[key] then
                seen[key] = true
                table.insert(list, key)
            end
        end
    end
    -- Semver-aware ascending sort. Falls back to string comparison for non-semver
    -- versions (e.g. git refs), which a small number of packages use. Matches the
    -- pattern in scripts/build_artifacts.lua.
    table.sort(list, function(a, b)
        if semver.is_valid(a) and semver.is_valid(b) then
            return semver.compare(a, b) < 0
        end
        return a < b
    end)
    return list
end

-- Strip a leading "v" tag prefix from versions like "v0.1.30" so the emitted
-- value matches how downstream trackers (repology, etc.) canonicalize it.
-- Leaves "1.2.10" / "2025.06.07" untouched.
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
    -- carries a per-URL transform xmake applies before substituting $(version).
    -- For repology this matters most for "v"-prefixed tags (libthai) and for
    -- packages that compute path components from the semver (sqlite3).
    local effective = version
    local filter = instance:url_version(url)
    if filter then
        -- xmake passes a semver object (see modules/.../utils/filter.lua); fall
        -- back to the raw string for non-semver versions like "2025.06.07" or
        -- 4-segment versions like "0.8.2.0" where semver.new() raises.
        local arg = version
        try {
            function () arg = semver.new(version) end,
            catch { function () end }
        }
        arg = arg or version
        local result = filter(arg)
        if result ~= nil then
            effective = tostring(result)
        end
    end
    -- Escape "%" in the replacement so URL templates like "ACE%2BTAO-..." (tao_idl)
    -- aren't interpreted as gsub back-references.
    local repl = (effective:gsub("%%", "%%%%"))
    local resolved = url:gsub("%$%(version%)", repl)
    local repl_nodot = (effective:gsub("%.", ""):gsub("%%", "%%%%"))
    resolved = resolved:gsub("%$%(version_nodot%)", repl_nodot)
    return resolved
end

function _urls_list(instance)
    -- instance:urls() is scheme-aware, so it also sees urls added dynamically
    -- by on_source() (cmake), and falls back to the set_base(...) base package
    -- (curl -> libcurl). Both return raw templates: $(version) placeholders
    -- are resolved later against the latest version.
    local urls
    if instance.urls then
        urls = instance:urls()
    else
        urls = instance:get("urls")
    end
    if not urls then
        return {}
    end
    if type(urls) == "string" then
        return {urls}
    end
    return urls
end

-- Treat ".git" / "git://" / "git+..." URLs as repository pointers, not download
-- URLs. The "git://" scheme covers GNU Savannah-hosted projects (autoconf, ...)
-- where the URL has no ".git" suffix.
function _is_git_url(url)
    if type(url) ~= "string" then
        return false
    end
    return url:find("^git%+") ~= nil
        or url:find("^git://") ~= nil
        or url:find("%.git$") ~= nil
end

function _download_urls(instance, version)
    -- Skip ".git" entries: repology wants file URLs in download_urls.
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
-- unambiguous version-archive markers (i.e. not just a coincidentally-named
-- directory on a tarball mirror like download.imagemagick.org/.../releases/...).
local _forge_hosts = {
    ["github.com"]    = true,
    ["gitlab.com"]    = true,
    ["bitbucket.org"] = true,
    ["codeberg.org"]  = true,
    ["gitea.com"]     = true,
    ["gitee.com"]     = true,
}

-- Strip per-version archive/release path segments and ".git" suffixes so that a
-- download URL collapses to the bare "<scheme>://<host>/<owner>/<repo>" root.
-- Returns nil for URLs that do not match a recognized forge layout — those are
-- typically vendor tarball mirrors (e.g. ftpmirror.gnu.org) that do not point at
-- a repository root and should not be reported as repository_url.
function _normalize_repo_url(url)
    if type(url) ~= "string" then
        return nil
    end
    url = url:gsub("^git%+", "")
    -- GitLab "/-/archive/" is a forge-specific marker — accept any host so that
    -- self-hosted instances (gitlab.gnome.org, code.videolan.org, ...) work.
    local root = url:match("^(https?://[^/]+/[^/]+/[^/]+)/%-/archive/")
    if root then
        return root
    end
    -- Bare ".git" URL — also unambiguous, accept any host.
    root = url:match("^(https?://[^/]+/[^/]+/[^/]+)%.git$")
    if root then
        return root
    end
    -- "/archive/", "/releases/", "/get/" can occur as ordinary directory names
    -- on tarball mirrors, so only strip them on hosts where we know the path
    -- segment is forge-specific.
    local host = url:match("^https?://([^/]+)/")
    if host and _forge_hosts[host] then
        root = url:match("^(https?://[^/]+/[^/]+/[^/]+)/archive/")
            or url:match("^(https?://[^/]+/[^/]+/[^/]+)/releases/")
            or url:match("^(https?://[^/]+/[^/]+/[^/]+)/get/")
        if root then
            return root
        end
    end
    return nil
end

function _homepage_as_repo_url(homepage)
    if type(homepage) ~= "string" then
        return nil
    end
    local host, rest = homepage:match("^https?://([^/]+)/(.+)$")
    if not host or not _forge_hosts[host] then
        return nil
    end
    -- Require exactly "<owner>/<repo>" (with optional trailing slash) so we
    -- don't mistake URLs like github.com/owner/repo/wiki for a repo root.
    local owner, repo = rest:match("^([^/]+)/([^/]+)/?$")
    if not owner or not repo then
        return nil
    end
    return ("https://%s/%s/%s"):format(host, owner, repo)
end

function _repository_url(instance, homepage)
    -- Prefer a verbatim ".git" URL declared in add_urls — repology asked for
    -- repository_url to be the raw git URL with the ".git" suffix preserved.
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

-- Patches applied to the given version, as repo-relative paths (or verbatim
-- URLs for remote patches). Mirrors scheme.lua:patches(): exact version key
-- first, then semver range keys like ">=1.0.0" or "*". Relative paths are
-- resolved against the package scriptdir (falling back to the set_base(...)
-- package), like xmake does when applying patches at install time.
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
    -- public accessors below (versions(), urls(), url_version(), get(...))
    -- all fall back to the base package on their own once _BASE is attached
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

-- Merge the per-profile candidates for one package: union of versions, entry
-- fields from the profile that carries the newest version (so version and
-- download_urls stay consistent), download url mirrors from every profile
-- that agrees on that version.
function _merge_candidates(candidates)
    local best
    for _, candidate in ipairs(candidates) do
        if candidate.version then
            if not best then
                best = candidate
            else
                local a, b = best.version, candidate.version
                local newer
                if semver.is_valid(a) and semver.is_valid(b) then
                    newer = semver.compare(b, a) > 0
                else
                    newer = b > a
                end
                if newer then
                    best = candidate
                end
            end
        end
    end
    if not best then
        return nil
    end
    local versions, seen = {}, {}
    local urls, seen_urls = {}, {}
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
        end
    end
    table.sort(versions, function(a, b)
        if semver.is_valid(a) and semver.is_valid(b) then
            return semver.compare(a, b) < 0
        end
        return a < b
    end)
    best.versions = versions
    if #urls > 0 then
        best.download_urls = urls
        best.download_url = urls[1]
    end
    return best
end

function main()
    local core = _core_package_module()
    local hooks_ok = _install_synthetic_hooks(core)

    local entries = {}
    local no_version = {}
    local missing = {}
    local skipped = {}
    for _, packagedir in ipairs(os.dirs(path.join("packages", "*", "*"))) do
        local packagename = path.filename(packagedir)
        local packagefile = path.join(packagedir, "xmake.lua")
        -- Isolate per-package failures: a broken filter or missing field in one
        -- xmake.lua must not abort the whole generator.
        try {
            function ()
                local entry = _load_entry(packagename, packagedir, packagefile)
                if entry then
                    if entry.version then
                        table.insert(entries, entry)
                    elseif hooks_ok then
                        table.insert(missing, {name = packagename, dir = packagedir, file = packagefile, entry = entry})
                    else
                        table.insert(no_version, packagename)
                    end
                end
            end,
            catch {
                function (errors)
                    table.insert(skipped, {name = packagename, error = tostring(errors)})
                end
            }
        }
    end

    -- Second chance for packages whose versions hide behind host/plat/arch
    -- conditionals: re-load them under each synthetic profile and merge.
    for _, item in ipairs(missing) do
        local candidates = {}
        for _, profile in ipairs(_synthetic_profiles) do
            try {
                function ()
                    _uncache_package(core, item.name, item.entry.base)
                    _synthetic.host = profile.host
                    _synthetic.os_arch = profile.os_arch
                    local entry = _load_entry(item.name, item.dir, item.file,
                        {plat = profile.plat, arch = profile.arch})
                    if entry and entry.version then
                        table.insert(candidates, entry)
                    end
                end,
                catch { function () end }
            }
            _synthetic.host = nil
            _synthetic.os_arch = nil
        end
        _uncache_package(core, item.name, item.entry.base)
        local merged = _merge_candidates(candidates)
        if merged then
            table.insert(entries, merged)
        else
            table.insert(no_version, item.name)
        end
    end

    table.sort(entries, function(a, b) return a.name < b.name end)

    local manifest = {
        generated_at = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        count        = #entries,
        packages     = entries,
    }

    os.mkdir("dist")
    local outpath = path.join("dist", "repology_packages_index.json")
    json.savefile(outpath, manifest)
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
