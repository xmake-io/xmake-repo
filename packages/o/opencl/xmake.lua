package("opencl")

    set_homepage("https://opencl.org/")
    set_description("OpenCL is an open, royalty-free industry standard that makes much faster computations possible through parallel computing.")

    if is_plat("windows") then
        if is_arch("x86", "i386") then
            set_urls("https://github.com/KhronosGroup/OpenCL-SDK/releases/download/$(version)/OpenCL-SDK-$(version)-Win-x86.zip")
            add_versions("v2023.04.17", "ff6fa1b4e311a3f655eff4eda28008ec48dccd559ec3ed95ce6d9a584cd3b581")
        elseif is_arch("x64") then
            set_urls("https://github.com/KhronosGroup/OpenCL-SDK/releases/download/$(version)/OpenCL-SDK-$(version)-Win-x64.zip")
            add_versions("v2023.04.17", "11844a1d69a71f82dc14ce66382c6b9fc8a4aee5840c21a786c5accb1d69bc0a")
        end
    else 
        set_urls("https://github.com/KhronosGroup/OpenCL-SDK.git")
        add_versions("v2023.04.17", "ae7fcae82fe0b7bcc272e43fc324181b2d544eea")
    end 
    
    add_configs("vendor", {description = "Set OpenCL Vendor.", default = nil, type = "string", values = {"nvidia", "intel", "amd"}})

    if not is_plat("windows") then
        add_deps("cmake")
    end

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

    on_install("windows|x86", "windows|x64", function (package)
        os.cp("lib", package:installdir())
        os.cp("bin", package:installdir())
        os.cp("include", package:installdir())
    end)

    on_install("linux", "macosx", "android", function (package)
        local configs = {"-DOPENCL_SDK_BUILD_SAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)
