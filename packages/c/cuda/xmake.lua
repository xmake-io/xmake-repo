package("cuda")
    set_kind("toolchain")
    set_homepage("https://developer.nvidia.com/cuda-zone/")
    set_description("CUDA® is a parallel computing platform and programming model developed by NVIDIA for general computing on graphical processing units (GPUs).")

    if is_host("windows") then
        add_urls("https://developer.download.nvidia.com/compute/cuda/$(version)_windows.exe", {
            version = function (version)
                local driver_version_map = {
                    ["12.8.1"] = "572.61",
                    ["12.6.3"] = "561.17",
                }
                return format("%s/local_installers/cuda_%s_%s", version, version, driver_version_map[tostring(version)])
            end})

        add_versions("12.8.1", "19392bbffd0ad4ee7cb295a181e87f682187f17653679c1c548c263b7e1cd9a6")
        add_versions("12.6.3", "d73e937c75aaa8114da3aff4eee96f9cae03d4b9d70a30b962ccf3c9b4d7a8e1")
    end

    add_configs("utils", {description = "Enabled cuda utilities.", default = {}, type = "table"})
    add_configs("debug", {description = "Enable debug symbols.", default = false, type = "boolean", readonly = true})

    set_policy("package.precompiled", false)

    on_fetch(function (package, opt)
        if opt.system then
            import("detect.sdks.find_cuda")
            import("lib.detect.find_library")

            local cuda = find_cuda()
            if cuda then
                local result = {includedirs = cuda.includedirs, linkdirs = cuda.linkdirs, links = {}}
                local utils = package:config("utils")
                table.insert(utils, package:config("shared") and "cudart" or "cudart_static")

                for _, util in ipairs(utils) do
                    if not find_library(util, cuda.linkdirs) then
                        wprint(format("The library %s for %s is not found!", util, package:arch()))
                        return
                    end
                    table.insert(result.links, util)
                end
                return result
            end
        end
    end)

    on_load("windows", function (package)
        package:mark_as_pathenv("CUDA_PATH")
        package:setenv("CUDA_PATH", ".")
    end)

    on_install("windows|x64", function(package)
        import("lib.detect.find_tool")
        import("lib.detect.find_directory")

        if package:is_plat("windows") then
            local z7 = assert(find_tool("7z"), "7z tool not found!")
            os.vrunv(z7.program, {"x", "-y", package:originfile()})

            -- reference: https://github.com/ScoopInstaller/Main/blob/master/bucket/cuda.json
            local names = {"bin", "extras", "include", "lib", "libnvvp", "nvml", "nvvm", "compute-sanitizer"}
            for _, dir in ipairs(os.dirs("*")) do
                if dir:startswith("cuda_") or dir:startswith("lib") then
                    for _, name in ipairs(names) do
                        local util_dir = find_directory(name, path.join(dir, "*"))
                        if util_dir then
                            os.vcp(path.join(util_dir, "*"), package:installdir(name))
                        end
                    end
                end
            end
        end
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.vrun("nvcc -V")
        end
    end)
