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
--         "version":        "<latest version>",
--         "description":    "<set_description(...)>",
--         "license":        "<set_license(...)>",
--         "homepage":       "<set_homepage(...)>",
--         "repository_url": "<normalized from add_urls(...), homepage fallback>",
--         "download_url":   "<first add_urls(...) entry with $(version) resolved>"
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
    -- `add_versions(v, sha)` stores entries as a hash {version = sha256, ...}, so
    -- we collect keys and sort them ourselves to pick the latest.
    local list = {}
    for v, _ in pairs(versions) do
        table.insert(list, tostring(v))
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

function _resolve_url(url, version)
    if not url then
        return nil
    end
    if not version then
        -- Leave the placeholder rather than emitting a literal "$(version)" in the manifest.
        return nil
    end
    url = url:gsub("%$%(version%)", version)
    url = url:gsub("%$%(version_nodot%)", (version:gsub("%.", "")))
    return url
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

function _first_download_url(instance, version)
    -- xmake convention: the first entry is the primary fetch source for the package.
    local urls = _urls_list(instance)
    return _resolve_url(urls[1], version)
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
        version        = version,
        description    = instance:get("description"),
        license        = instance:get("license"),
        homepage       = instance:get("homepage"),
        repository_url = _repository_url(instance),
        download_url   = _first_download_url(instance, version),
    }
end

function main()
    local entries = {}
    for _, packagedir in ipairs(os.dirs(path.join("packages", "*", "*"))) do
        local packagename = path.filename(packagedir)
        local packagefile = path.join(packagedir, "xmake.lua")
        local instance = _load_package(packagename, packagedir, packagefile)
        if instance and not instance:is_template() then
            table.insert(entries, _entry(instance))
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
end
