-- imports
import("core.package.package")
import("core.platform.platform")
import("private.core.base.select_script")

-- is supported platform and architecture?
function is_supported(instance, plat, arch, opt)
    if instance:is_template() then
        return false
    end

    local script = instance:get(instance:is_fetchonly() and "fetch" or "install")
    if not select_script(script, {plat = plat, arch = arch}) then
        return false
    end
    return true
end

-- load package
function _load_package(packagename, packagedir, packagefile)
    local funcinfo = debug.getinfo(package.load_from_repository)
    if funcinfo and funcinfo.nparams == 3 then -- >= 2.7.8
        return package.load_from_repository(packagename, packagedir, {packagefile = packagefile})
    else
        -- deprecated
        return package.load_from_repository(packagename, nil, packagedir, packagefile)
    end
end

-- the main entry
function main(opt)
    local packages = {}
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
            for _, plat in ipairs({"windows", "linux", "macosx", "iphoneos", "android", "mingw", "msys", "bsd", "wasm", "cross"}) do
                local archs = platform.archs(plat)
                if archs then
                    local package_archs = {}
                    for _, arch in ipairs(archs) do
                        if is_supported(instance, plat, arch, opt) then
                            table.insert(package_archs, arch)
                        end
                    end
                    if #package_archs > 0 then
                        packages[plat] = packages[plat] or {}
                        table.insert(packages[plat], {name = instance:name(), instance = instance, archs = package_archs, generic = #package_archs == #archs})
                    end
                end
            end
        end
    end
    for _, packages_plat in pairs(packages) do
        table.sort(packages_plat, function(a, b) return a.name < b.name end)
    end
    return packages
end
