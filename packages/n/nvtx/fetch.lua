import("lib.detect.find_path")
import("lib.detect.find_library")
import("detect.sdks.find_cuda")

function _find_package(package, opt)
    if package:is_plat("windows") then
        local rdir = (package:is_arch("x64") and "x64" or "Win32")
        local libname = (package:is_arch("x64") and "nvToolsExt64_1" or "nvToolsExt32_1")

        -- init search paths
        local paths = {
            "$(env NVTOOLSEXT_PATH)",
            "$(env PROGRAMFILES)/NVIDIA Corporation/NvToolsExt"
        }

        -- find library
        local result = {links = {}, linkdirs = {}, includedirs = {}, libfiles = {}}
        local linkinfo = find_library(libname, paths, {suffixes = path.join("lib", rdir)})
        if linkinfo then
            local nvtx_dir = path.directory(path.directory(linkinfo.linkdir))
            table.insert(result.linkdirs, linkinfo.linkdir)
            table.insert(result.links, libname)
            table.insert(result.libfiles, path.join(nvtx_dir, "bin", rdir, libname .. ".dll"))
            table.insert(result.libfiles, path.join(nvtx_dir, "lib", rdir, libname .. ".lib"))
        else
            -- not found?
            return
        end

        -- find include
        table.insert(result.includedirs, find_path("nvToolsExt.h", paths, {suffixes = "include"}))
        return result
    else
        local cuda = find_cuda()
        if cuda then
            local result = {links = {}, linkdirs = {}, includedirs = {}}

            -- find library
            local linkinfo = find_library("nvToolsExt", cuda.linkdirs)
            if linkinfo then
                table.insert(result.links, "nvToolsExt")
                table.insert(result.linkdirs, linkinfo.linkdir)
            else
                return
            end
            table.join2(result.includedirs, cuda.includedirs)
            return result
        end
    end
end

function main(package, opt)
    if opt.system then
        local result = _find_package(package, opt)
        if not result then
            result = package:find_package("nvtx", opt)
        end
        return result or false
    end
end
