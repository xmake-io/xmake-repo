package("cuda")

    set_homepage("https://developer.nvidia.com/cuda-zone/")
    set_description("CUDA® is a parallel computing platform and programming model developed by NVIDIA for general computing on graphical processing units (GPUs).")

    add_configs("utils", {description = "Enabled cuda utilities.", default = {}, type = "table"})

    on_load(function (package)
        import("detect.sdks.find_cuda")
        local cuda = find_cuda()
        if cuda then
            package:addenv("PATH", cuda.bindir)
        end
    end)

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
