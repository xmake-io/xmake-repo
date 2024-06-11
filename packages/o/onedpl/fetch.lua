import("lib.detect.find_path")
import("lib.detect.find_library")

function _find_package(package, opt)
    local paths = {
	    "$(env DPL_ROOT)",
        "$(env ONEAPI_ROOT)/dpl/latest"
    }
    -- find library
    local result = {links = {}, linkdirs = {}, includedirs = {}}

    -- find include
    local includepath = find_path(path.join("oneapi", "dpl", "algorithm"), paths, {suffixes = "include"})
    if includepath then
        table.insert(result.includedirs, includepath)
    end
	
    if #result.includedirs > 0  then
        local version_file = path.join(includepath, "oneapi", "dpl", "pstl", "onedpl_config.h")
        if os.isfile(version_file) then
            local content = io.readfile(version_file)
            local major = content:match("ONEDPL_VERSION_MAJOR +(%d+)\n")
            local minor = content:match("ONEDPL_VERSION_MINOR +(%d+)\n")
            local patch = content:match("ONEDPL_VERSION_PATCH +(%d+)\n")
            if patch then
                result.version = format("%s.%s.%s", major, minor, patch)
            else
                result.version = format("%s.%s", major, minor)
            end
        end
	
        return result
    end
end

function main(package, opt)
    if opt.system and package.find_package then
        local result = _find_package(package, opt)
        if not result then
            result = package:find_package("onedpl", opt)
        end
        return result or false
    end
end
