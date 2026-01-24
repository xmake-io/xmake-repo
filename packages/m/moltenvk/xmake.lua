package("moltenvk")
    set_homepage("https://github.com/KhronosGroup/MoltenVK")
    set_description("MoltenVK is a Vulkan Portability implementation.")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/MoltenVK/archive/refs/tags/$(version).tar.gz",
             "https://github.com/KhronosGroup/MoltenVK.git")

    add_versions("v1.4.1", "9985f141902a17de818e264d17c1ce334b748e499ee02fcb4703e4dc0038f89c")
    add_versions("v1.4.0", "fc74aef926ee3cd473fe260a93819c09fdc939bff669271a587e9ebaa43d4306")
    add_versions("v1.3.0", "9476033d49ef02776ebab288fffae3e28fd627a3e29b7ae5975a1e1c785bf912")
    add_versions("v1.2.11", "bfa115e283831e52d70ee5e13adf4d152de8f0045996cf2a33f0ac541be238b1")
    add_versions("v1.2.10", "3435d34ea2dafb043dd82ac5e9d2de7090462ab7cea6ad8bcc14d9c34ff99e9c")
    add_versions("v1.2.9", "f415a09385030c6510a936155ce211f617c31506db5fbc563e804345f1ecf56e")
    add_versions("v1.2.8", "85beaf8abfcc54d9da0ff0257ae311abd9e7aa96e53da37e1c37d6bc04ac83cd")
    add_versions("v1.2.7", "3166edcfdca886b4be1a24a3c140f11f9a9e8e49878ea999e3580dfbf9fe4bec")
    add_versions("v1.2.0", "6e7af2dad0530b2b404480dbe437ca4670c6615cc2ec6cf6a20ed04d9d75e0bd")
    add_versions("v1.1.5", "2cdcb8dbf2acdcd8cbe70b109dadc05a901038c84970afbe4863e5e23f33deae")
    add_versions("v1.1.4", "f9bba6d3bf3648e7685c247cb6d126d62508af614bc549cedd5859a7da64967e")
    add_versions("v1.1.0", "0538fa1c23ddae495c7f82ccd0db90790a90b7017a258ca7575fbae8021f3058")

    add_configs("vk_driver", {description = "Path to MoltenVK", default = nil, type = "string"})

    if is_plat("macosx") then
        add_extsources("brew::molten-vk")
    end

    add_links("MoltenVK")

    if is_plat("macosx", "iphoneos") then
        add_frameworks("Metal", "Foundation", "QuartzCore", "CoreGraphics", "IOSurface")
        if is_plat("macosx") then
            add_frameworks("IOKit", "AppKit")
        else
            add_frameworks("UIKit")
        end
    end

    on_fetch("macosx", function (package, opt)
        if opt.system then
            import("lib.detect.find_path")
            local vk_driver = package:config("vk_driver")
            if vk_driver then
                -- This value can be a dir or a file(dylib, a or json) path
                -- e.g. /home/xxx/dev/MoltenVK/MoltenVK/dynamic/dylib/macOS/libMoltenVK.dylib
                --      /home/xxx/dev/MoltenVK/MoltenVK/dynamic/dylib/macOS/MoltenVK_icd.json
                --      /home/xxx/dev/MoltenVK/MoltenVK
                local moltenvk_dir
                if os.isfile(vk_driver) then
                    local _, e = vk_driver:find("MoltenVK.framework", 1, true)
                    if not e then
                        _, e = vk_driver:find("MoltenVK", 1, true)
                    end
                    if e then
                        moltenvk_dir = vk_driver:sub(1, e)
                    end
                end
                if os.isdir(vk_driver) then
                    moltenvk_dir = vk_driver
                end

                if moltenvk_dir then
                    local frameworkdir = find_path("**/macos*/MoltenVK.framework", moltenvk_dir)
                    frameworkdir = os.dirs(path.join(frameworkdir, "macos*"))
                    if frameworkdir and #frameworkdir > 0 then
                        frameworkdir = frameworkdir[1]
                        return { frameworkdirs = frameworkdir, frameworks = "MoltenVK", rpathdirs = frameworkdir }
                    end
                end
            end

            local frameworkdir = find_path("vulkan.framework", "~/VulkanSDK/*/macOS/Frameworks")
            if frameworkdir then
                return { frameworkdirs = frameworkdir, frameworks = "vulkan", rpathdirs = frameworkdir }
            end
        end
    end)

    on_install("macosx", "iphoneos", function (package)
        local plat = package:is_plat("iphoneos") and "iOS" or "macOS"
        local configs = {"--" .. plat:lower()}
        if package:is_debug() then
            table.insert(configs, "--debug")
        end
        os.vrunv("./fetchDependencies", configs)
        
        local conf = package:is_debug() and "Debug" or "Release"
        local moltenvk_rootdir = path.join("Package", conf, "MoltenVK")
        local moltenvk_shader_rootdir = path.join("Package", conf, "MoltenVKShaderConverter")
        
        os.vrunv("xcodebuild", {
            "build",
            "-quiet",
            "-project", "MoltenVKPackaging.xcodeproj", 
            "-scheme", "MoltenVK Package (" .. plat .. " only)",
            "-configuration", conf
        })
        
        os.mv(path.join(moltenvk_rootdir, "include"), package:installdir())
        os.mv(path.join(moltenvk_rootdir, "dylib", plat, "*"), package:installdir("lib"))
        os.mv(path.join(moltenvk_rootdir, "MoltenVK.xcframework", plat:lower() .. "-*", "*.a"), package:installdir("lib"))
        
        if package:config("shared") then
            os.mv(path.join(moltenvk_rootdir, "dynamic", "dylib", plat, "*.dylib"), package:installdir("lib"))
        else
            os.mv(path.join(moltenvk_rootdir, "static", "MoltenVK.xcframework", plat:lower() .. "-*", "*.a"), package:installdir("lib"))
        end
        
        os.mv(path.join(moltenvk_shader_rootdir, "Tools", "*"), package:installdir("bin"))
        os.mv(path.join(moltenvk_shader_rootdir, "MoltenVKShaderConverter.xcframework", plat:lower() .. "-*", "*.a"), package:installdir("lib"))
        os.mv(path.join(moltenvk_shader_rootdir, "include", "*.h"), package:installdir("include"))
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:has_cfuncs("vkGetDeviceProcAddr", {includes = "vulkan/vulkan_core.h"}))
    end)
