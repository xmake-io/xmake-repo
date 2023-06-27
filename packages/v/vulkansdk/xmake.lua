package("vulkansdk")

    set_homepage("https://www.lunarg.com/vulkan-sdk/")
    set_description("LunarG Vulkan® SDK")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})
    add_configs("utils",  {description = "Enabled vulkan utilities.", default = {}, type = "table"})

    on_load(function (package)
        import("detect.sdks.find_vulkansdk")
        local vulkansdk = find_vulkansdk()
        if vulkansdk then
            package:addenv("PATH", vulkansdk.bindir)
        end
    end)

    on_fetch(function (package, opt)
        if opt.system then
            import("detect.sdks.find_vulkansdk")
            import("lib.detect.find_library")

            local vulkansdk = find_vulkansdk()
            if vulkansdk then
                local result = {includedirs = vulkansdk.includedirs, linkdirs = vulkansdk.linkdirs, links = {}}
                local utils = package:config("utils")
                table.insert(utils, package:is_plat("windows") and "vulkan-1" or "vulkan")
        
                for _, util in ipairs(utils) do
                    if not find_library(util, vulkansdk.linkdirs) then
                        wprint(format("The library %s for %s is not found!", util, package:arch()))
                        return
                    end
                    table.insert(result.links, util)
                end
                return result
            end
        end
    end)
