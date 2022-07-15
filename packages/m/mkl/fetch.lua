import("lib.detect.find_path")
import("lib.detect.find_library")

function _find_package(package, opt)
    local rdir = (package:is_arch("x64", "x86_64") and "intel64" or "ia32")
    local suffix = (package:config("interface") == 32 and "lp64" or "ilp64")
    local paths = {
        "$(env MKL_ROOT)",
        "$(env ONEAPI_ROOT)\\mkl\\latest"
    }

    -- find library
    local result = {links = {}, linkdirs = {}, includedirs = {}}
    if package:config("interface") == 64 then
        result.defines = {"MKL_ILP64"}
    end
    local linkinfo = find_library("mkl_core", paths, {suffixes = {"lib", path.join("lib", rdir), path.join("lib", rdir, "gcc*")}})
    if not linkinfo then
        return
    end
    table.insert(result.linkdirs, linkinfo.linkdir)
    if rdir == "intel64" then
        table.insert(result.links, "mkl_blas95_" .. suffix)
        table.insert(result.links, "mkl_lapack95_" .. suffix)
    else
        table.insert(result.links, "mkl_blas95")
        table.insert(result.links, "mkl_lapack95")
    end

    local group = {}
    if rdir == "intel64" then
        table.insert(group, "mkl_intel_" .. suffix)
    elseif package:is_plat("windows") then
        table.insert(group, "mkl_intel_c")
    else
        table.insert(group, "mkl_intel")
    end

    local threading = package:config("threading")
    if threading == "tbb" then
        table.join2(group, {"mkl_tbb_thread", "mkl_core"})
    elseif threading == "seq" then
        table.join2(group, {"mkl_sequential", "mkl_core"})
    elseif threading == "openmp" then
        table.join2(group, {"mkl_intel_thread", "mkl_core"})
    end

    if package:has_tool("cc", "gcc", "gxx") then
        result.ldflags = "-Wl,--start-group "
        for _, lib in ipairs(group) do
            result.ldflags = result.ldflags .. "-l" .. lib .. " "
        end
        result.ldflags = result.ldflags .. "-Wl,--end-group"
    else
        table.join2(result.links, group)
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
