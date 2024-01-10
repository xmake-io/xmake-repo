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

function main()
    local count = 0
    local maxcount = 6
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
                count = count + 1
            end
        end
    end
end
