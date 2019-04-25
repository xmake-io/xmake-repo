-- imports
import("core.package.package")
import("core.platform.platform")

-- is supported platform and architecture?
function _is_supported(instance, plat, arch)

    -- get script
    local script = instance:get("install")
    local result = nil
    if type(script) == "function" then
        result = script
    elseif type(script) == "table" then

        -- get plat and arch
        local plat = plat or ""
        local arch = arch or ""

        -- match script for special plat and arch
        local pattern = plat .. '|' .. arch
        for _pattern, _script in pairs(script) do
            if not _pattern:startswith("__") and pattern:find('^' .. _pattern .. '$') then
                result = _script
                break
            end
        end

        -- match script for special plat
        if result == nil then
            for _pattern, _script in pairs(script) do
                if not _pattern:startswith("__") and plat:find('^' .. _pattern .. '$') then
                    result = _script
                    break
                end
            end
        end

        -- get generic script
        result = result or script["__generic__"]
    end
    return result
end

-- the main entry
function main(...)
    local packages = {}
    local plat = os.host()
    for _, packagedir in ipairs(os.dirs(path.join("packages", "*", "*"))) do
        local packagename = path.filename(packagedir)
        local packagefile = path.join(packagedir, "xmake.lua")
        local instance = package.load_from_repository(packagename, nil, packagedir, packagefile)
        if instance then
            for _, plat in ipairs({"windows", "linux", "macosx", "iphoneos", "android", "mingw"}) do
                local archs = platform.archs(plat)
                if archs then
                    local package_archs = {}
                    for _, arch in ipairs(archs) do
                        if _is_supported(instance, plat, arch) then
                            table.insert(package_archs, arch)
                        end
                    end
                    if #package_archs > 0 then
                        packages[plat] = packages[plat] or {}
                        table.insert(packages[plat], {name = instance:name(), archs = package_archs, generic = #package_archs == #archs})
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
