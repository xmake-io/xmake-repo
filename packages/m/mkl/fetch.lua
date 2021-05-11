import("lib.detect.find_path")
import("lib.detect.find_library")

function _find_package(package, opt)
    local rdir = (package:is_arch("x64", "x86_64") and "intel64" or "ia32")
    local paths = {
        "$(env MKL_ROOT)",
        "$(env ONEAPI_ROOT)\\mkl\\latest"
    }

    -- find library
    local result = {links = {}, linkdirs = {}, includedirs = {}}
    local linkinfo = find_library("mkl_core", paths, {suffixes = {"lib", path.join("lib", rdir), path.join("lib", rdir, "gcc*")}})
    if not linkinfo then
        return
    end
    table.insert(result.linkdirs, linkinfo.linkdir)
    if rdir == "intel64" then
        table.insert(result.links, "mkl_intel_ilp64")
    elseif package:is_plat("windows") then
        table.insert(result.links, "mkl_intel_c")
    else
        table.insert(result.links, "mkl_intel")
    end

    local threading = package:config("threading")
    if threading then
        if threading == "tbb" then
            table.join2(result.links, {"mkl_tbb_thread", "mkl_core"})
            package:add("deps", "tbb")
        elseif threading == "seq" then
            table.join2(result.links, {"mkl_sequential", "mkl_core"})
        elseif threading == "openmp" then
            table.join2(result.links, {"mkl_intel_thread", "mkl_core"})
        end
    else
        if find_package("tbb") then
            table.join2(result.links, {"mkl_tbb_thread", "mkl_core"})
            package:add("deps", "tbb")
        else
            table.join2(result.links, {"mkl_sequential", "mkl_core"})
        end
    end

    -- find include
    local includepath = find_path(path.join("mkl.h"), paths, {suffixes = "include"})
    if includepath then
        table.insert(result.includedirs, includepath)
    end

    if #result.includedirs > 0 and #result.linkdirs > 0 then
        local version_file = path.join(includepath, "mkl_version.h")
        if os.isfile(version_file) then
            local content = io.readfile(version_file)
            local major = content:match("__INTEL_MKL__ +(%d+)\n")
            local minor = content:match("__INTEL_MKL_MINOR__ +(%d+)\n")
            local patch = content:match("__INTEL_MKL_UPDATE__ +(%d+)\n")
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
            result = package:find_package("mkl", opt)
        end
        return result or false
    end
end
