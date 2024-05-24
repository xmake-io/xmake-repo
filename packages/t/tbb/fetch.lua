import("lib.detect.find_path")
import("lib.detect.find_library")

function _find_package_on_windows(package, opt)
    local rdir = (package:is_arch("x64") and "intel64" or "ia32")
    local paths = {
        "$(env TBB_ROOT)",
        "$(env ONEAPI_ROOT)\\tbb\\latest"
    }

    -- find includes and links
    local result = {links = {}, linkdirs = {}, includedirs = {}}
    for _, lib in ipairs({"tbb", "tbbmalloc", "tbbmalloc_proxy"}) do
        local linkinfo = find_library(lib, paths, {suffixes = {"lib", path.join("lib", rdir, "vc14")}})
        if linkinfo then
            table.insert(result.linkdirs, linkinfo.linkdir)
            table.insert(result.links, lib)
        end
    end
    result.linkdirs = table.unique(result.linkdirs)
    local incpath = find_path(path.join("tbb", "tbb.h"), paths, {suffixes = "include"})
    if incpath then
        table.insert(result.includedirs, incpath)
    end

    if #result.includedirs > 0 and #result.linkdirs > 0 then
        local version_file = path.join(incpath, "oneapi", "tbb", "version.h")
        if not os.isfile(version_file) then
            version_file = path.join(incpath, "tbb", "tbb_stddef.h")
        end
        if os.isfile(version_file) then
            local content = io.readfile(version_file)
            local major = content:match("TBB_VERSION_MAJOR (%d+)\n")
            local minor = content:match("TBB_VERSION_MINOR (%d+)\n")
            local patch = content:match("TBB_VERSION_PATCH (%d+)\n")
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
        local result
        if package:is_plat("windows") then
            result = _find_package_on_windows(package, opt)
        end
        if not result then
            result = package:find_package("tbb", opt)
        end
        return result or false
    end
end
