import("core.package.package")
import("core.base.semver")
import("core.base.hashset")
import("packages", {alias = "packages_util"})

function _load_package(packagename, packagedir, packagefile)
    local funcinfo = debug.getinfo(package.load_from_repository)
    if funcinfo and funcinfo.nparams == 3 then -- >= 2.7.8
        return package.load_from_repository(packagename, packagedir, {packagefile = packagefile})
    else
        -- deprecated
        return package.load_from_repository(packagename, nil, packagedir, packagefile)
    end
end

function _get_all_packages()
    local packages = _g.packages
    if not packages then
        packages = {}
        for _, packagedir in ipairs(os.dirs(path.join("packages", "*", "*"))) do
            local packagename = path.filename(packagedir)
            local packagefile = path.join(packagedir, "xmake.lua")
            local instance = _load_package(packagename, packagedir, packagefile)
            local basename = instance:get("base")
            if instance and basename then
                local basedir = path.join("packages", basename:sub(1, 1):lower(), basename:lower())
                local basefile = path.join(basedir, "xmake.lua")
                instance._BASE = _load_package(basename, basedir, basefile)
            end
            if instance then
                table.insert(packages, instance)
            end
        end
        _g.packages = packages
    end
    return packages
end

function _update_version(instance, version, shasum)
    local branch = "autoupdate-" .. instance:name() .. "-" .. version
    local branch_current = os.iorun("git branch --show-current"):trim()
    os.exec("git stash")
    os.exec("git branch -D %s", branch)
    os.exec("git branch %s", branch)
    os.exec("git checkout %s", branch)
    local scriptfile = path.join(instance:scriptdir(), "xmake.lua")
    if os.isfile(scriptfile) then
        local inserted = false
        local version_current
        io.gsub(scriptfile, "add_versions%(\"(.-)\",%s+\"(.-)\"%)", function (v, h)
            if not version_current or sermver.compare(v, version_current) > 0 then
                version_current = v
            end
            if not inserted then
                inserted = true
                return string.format('add_versions("%s", "%s")\n    add_versions("%s", "%s")', version, shasum, v, h)
            end
        end)
        local body = string.format("New version of %s detected (package version: %s, last github version: %s)",
            instance:name(), version_current, version)
        os.exec("git add .")
        os.exec("git commit -a -m \"Update %s to %s\"", instance:name(), version)
        os.exec("gh pr create --title \"Auto-update %s to %s\" --body \"%s\" -R xmake-io/xmake-repo", instance:name(), version, body)
    end
    os.exec("git reset --hard HEAD")
    os.exec("git checkout %s", branch_current)
    os.exec("git stash pop")
end

function main(maxcount)
    local count = 0
    local maxcount = tonumber(maxcount or 10)
    local instances = _get_all_packages()
    for _, instance in ipairs(instances) do
        local checkupdate_filepath = path.join(instance:scriptdir(), "checkupdate.lua")
        if not os.isfile(checkupdate_filepath) then
            checkupdate_filepath = path.join(os.scriptdir(), "checkupdate.lua")
        end
        if os.isfile(checkupdate_filepath) and count < maxcount then
            local checkupdate = import("checkupdate", {rootdir = path.directory(checkupdate_filepath), anonymous = true})
            local version, shasum = checkupdate(instance)
            if version and shasum then
                cprint("package(%s): new version ${bright}%s${clear} found, shasum: ${bright}%s", instance:name(), version, shasum)
                _update_version(instance, version, shasum)
                count = count + 1
            end
        end
    end
end
