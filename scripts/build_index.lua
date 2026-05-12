-- Generate a flat JSON index of all packages in this repository.
--
-- Output: dist/packages.json
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
--         "repository_url": "<set_homepage(...)>",          -- canonical project URL
--         "download_url":   "<first add_urls(...) entry with $(version) resolved>"
--       },
--       ...
--     ]
--   }
--
-- Run:  xmake l scripts/build_index.lua

import("core.base.json")
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
    -- Prefer the ordered list if exposed; otherwise sort the hash table keys.
    local versions = instance:get("versions")
    if not versions then
        return nil
    end
    local list = {}
    if type(versions) == "table" then
        if #versions > 0 then
            -- list-like (ordered)
            return versions[#versions]
        end
        for v, _ in pairs(versions) do
            table.insert(list, tostring(v))
        end
    end
    if #list == 0 then
        return nil
    end
    table.sort(list)
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

function _first_download_url(instance, version)
    local urls = instance:get("urls")
    if not urls then
        return nil
    end
    if type(urls) == "string" then
        return _resolve_url(urls, version)
    end
    -- xmake convention: the first entry is the primary fetch source for the package.
    return _resolve_url(urls[1], version)
end

function _entry(instance)
    local version = _latest_version(instance)
    local homepage = instance:get("homepage")
    return {
        name           = instance:name(),
        version        = version,
        description    = instance:get("description"),
        license        = instance:get("license"),
        homepage       = homepage,
        repository_url = homepage,  -- homepage is, by convention, the canonical project URL
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
    local outpath = path.join("dist", "packages.json")
    json.savefile(outpath, manifest)
    cprint("${green}wrote${clear} %s (%d packages)", outpath, #entries)
end
