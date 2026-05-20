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
--         "description":    "<set_description(...)>",
--         "license":        "<set_license(...)>",
--         "homepage":       "<set_homepage(...)>",
--         "repository_url": "<verbatim .git URL from add_urls, normalized forge URL, or homepage fallback>",
--         "download_url":   "<first non-.git add_urls(...) entry with $(version) resolved through the per-URL filter>"
--       },
--       ...
--     ]
--   }
--
-- Run:  xmake l scripts/build_index.lua

import("core.base.json")
import("core.base.semver")
import("core.package.package")

-- Match the loader pattern used by scripts/packages.lua and scripts/autoupdate.lua.
function _load_package(packagename, packagedir, packagefile)
    local funcinfo = debug.getinfo(package.load_from_repository)
    if funcinfo and funcinfo.nparams == 3 then -- >= 2.7.8
        return package.load_from_repository(packagename, packagedir, {packagefile = packagefile})
    else
        return package.load_from_repository(packagename, nil, packagedir, packagefile)
    end
end

function _latest_version(instance)
    local versions = instance:get("versions")
    if not versions or type(versions) ~= "table" then
        return nil
    end
    -- `add_versions("alias:1.2.3", sha)` stores entries keyed by `<alias>:<version>`;
    -- strip the alias prefix and dedupe so 1.2.3 appears once even when multiple
    -- mirrors are declared. Matches scheme.lua:versions() in xmake core.
    local seen = {}
    local list = {}
    for v, _ in pairs(versions) do
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
    if #list == 0 then
        return nil
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
    return list[#list]
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
    local urls = instance:get("urls")
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

function _pick_download_url(instance, version)
    -- Skip ".git" entries: repology wants a file URL in download_url.
    for _, url in ipairs(_urls_list(instance)) do
        if not _is_git_url(url) then
            return _resolve_url(instance, url, version)
        end
    end
    return nil
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

function _repository_url(instance)
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
    return _homepage_as_repo_url(instance:get("homepage"))
end

function _entry(instance)
    local version = _latest_version(instance)
    return {
        name           = instance:name(),
        version        = _normalize_version_for_output(version),
        description    = instance:get("description"),
        license        = instance:get("license"),
        homepage       = instance:get("homepage"),
        repository_url = _repository_url(instance),
        download_url   = _pick_download_url(instance, version),
    }
end

function main()
    local entries = {}
    local skipped = {}
    for _, packagedir in ipairs(os.dirs(path.join("packages", "*", "*"))) do
        local packagename = path.filename(packagedir)
        local packagefile = path.join(packagedir, "xmake.lua")
        -- Isolate per-package failures: a broken filter or missing field in one
        -- xmake.lua must not abort the whole generator.
        try {
            function ()
                local instance = _load_package(packagename, packagedir, packagefile)
                if instance and not instance:is_template() then
                    table.insert(entries, _entry(instance))
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

    local manifest = {
        generated_at = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        count        = #entries,
        packages     = entries,
    }

    os.mkdir("dist")
    local outpath = path.join("dist", "repology_packages_index.json")
    json.savefile(outpath, manifest)
    cprint("${green}wrote${clear} %s (%d packages)", outpath, #entries)
    if #skipped > 0 then
        cprint("${yellow}skipped${clear} %d package(s):", #skipped)
        for _, s in ipairs(skipped) do
            cprint("  %s: %s", s.name, s.error)
        end
    end
end
