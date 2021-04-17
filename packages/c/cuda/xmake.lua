package("cuda")

    set_homepage("https://developer.nvidia.com/cuda-zone/")
    set_description("CUDA® is a parallel computing platform and programming model developed by NVIDIA for general computing on graphical processing units (GPUs).")

    add_configs("utils", {description = "enabled cuda utilities.", default = {}, type = "table"})

    on_fetch(function (package, opt)
        if opt.system then
            import("detect.sdks.find_cuda")
            import("lib.detect.find_library")

            local cuda = find_cuda()
            if cuda then
                package:addenv("PATH", cuda.bindir)
                local result = {includedirs = cuda.includedirs, linkdirs = cuda.linkdirs, links = {}}
                local utils = package:config("utils")
                table.insert(utils, package:config("shared") and "cudart" or "cudart_static")
        
                for _, util in ipairs(utils) do
                    if not find_library(util, cuda.linkdirs) then
                        return
                    end
                    table.insert(result.links, util)
                end
                return result
            end
        end
    end)
