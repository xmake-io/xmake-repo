package("opencl")

    set_homepage("https://opencl.org/")
    set_description("OpenCL is an open, royalty-free industry standard that makes much faster computations possible through parallel computing.")

    add_configs("vendor", {description = "Set OpenCL Vendor.", default = nil, type = "string", values = {"nvidia", "intel", "amd"}})

    on_fetch(function (package, opt)
        if opt.system then
            import("lib.detect.find_path")
            import("lib.detect.find_library")
            import("detect.sdks.find_cuda")

            local result = {includedirs = {}, linkdirs = {}, links = {"OpenCL"}}
            local vendor = package:config("vendor")
            local archsuffixes = {"lib"}
            if package:is_arch("x64") then
                table.insert(archsuffixes, "lib64")
                table.insert(archsuffixes, path.join("lib", "x64"))
            elseif package:is_arch("x86", "i386") then
                table.insert(archsuffixes, path.join("lib", "x86"))
            elseif package:is_arch("x86_64") then
                table.insert(archsuffixes, "lib64")
                table.insert(archsuffixes, path.join("lib", "x86_64"))
            end

            if not vendor or vendor == "nvidia" then
                local cuda = find_cuda()
                if cuda then
                    result.includedirs = cuda.includedirs
                    result.linkdirs = cuda.linkdirs
                    return result
                elseif vendor == "nvidia" then
                    return nil
                end
            elseif not vendor or vendor == "intel" then
                local intelsdkpaths = {"$(env INTELOCLSDKROOT)"}
                local linkinfo = find_library("OpenCL", intelsdkpaths, {suffixes = archsuffixes})
                if linkinfo then
                    table.insert(result.linkdirs, linkinfo.linkdir)
                    local incpath = find_path(path.join("CL", "cl.h"), intelsdkpaths, {suffixes = {"include"}})
                    if incpath then
                        table.insert(result.includedirs, incpath)
                        return result
                    end
                end
                if vendor == "intel" then
                    return nil
                end
            elseif not vendor or vendor == "amd" then
                local amdsdkpaths = {"$(env AMDAPPSDKROOT)"}
                local linkinfo = find_library("OpenCL", amdsdkpaths, {suffixes = archsuffixes})
                if linkinfo then
                    table.insert(result.linkdirs, linkinfo.linkdir)
                    local incpath = find_path(path.join("CL", "cl.h"), amdsdkpaths, {suffixes = {"include"}})
                    if incpath then
                        table.insert(result.includedirs, incpath)
                        return result
                    end
                end
                if vendor == "amd" then
                    return nil
                end
            end
        end
    end)
