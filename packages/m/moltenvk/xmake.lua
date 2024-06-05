package("moltenvk")
    set_homepage("https://github.com/KhronosGroup/MoltenVK")
    set_description("MoltenVK is a Vulkan Portability implementation.")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/MoltenVK/archive/refs/tags/$(version).tar.gz",
             "https://github.com/KhronosGroup/MoltenVK.git")
    add_versions("v1.2.8", "85beaf8abfcc54d9da0ff0257ae311abd9e7aa96e53da37e1c37d6bc04ac83cd")
    add_versions("v1.2.7", "3166edcfdca886b4be1a24a3c140f11f9a9e8e49878ea999e3580dfbf9fe4bec")
    add_versions("v1.2.0", "6e7af2dad0530b2b404480dbe437ca4670c6615cc2ec6cf6a20ed04d9d75e0bd")
    add_versions("v1.1.5", "2cdcb8dbf2acdcd8cbe70b109dadc05a901038c84970afbe4863e5e23f33deae")
    add_versions("v1.1.4", "f9bba6d3bf3648e7685c247cb6d126d62508af614bc549cedd5859a7da64967e")
    add_versions("v1.1.0", "0538fa1c23ddae495c7f82ccd0db90790a90b7017a258ca7575fbae8021f3058")

    if is_plat("macosx") then
        add_extsources("brew::molten-vk")
    end   

    on_fetch("macosx", function (package, opt)
        if opt.system then
            import("lib.detect.find_path")
            local frameworkdir = find_path("vulkan.framework", "~/VulkanSDK/*/macOS/Frameworks")
            if frameworkdir then
                return {frameworkdirs = frameworkdir, frameworks = "vulkan", rpathdirs = frameworkdir}
            end
        end
    end)

    on_install("macosx", "iphoneos", function (package)
        local plat = package:is_plat("iphoneos") and "iOS" or "macOS"
        local configs = {"--" .. plat:lower()}
        if package:debug() then
            table.insert(configs, "--debug")
        end
        os.vrunv("./fetchDependencies", configs)
        local conf = package:debug() and "Debug" or "Release"
        os.vrun("xcodebuild build -project MoltenVKPackaging.xcodeproj -scheme \"MoltenVK Package (" ..plat .. " only)\" -configuration \"" .. conf)
        os.mv("Package/" .. conf .. "/MoltenVK/include", package:installdir())
        os.mv("Package/" .. conf .. "/MoltenVK/dylib/" ..plat .. "/*", package:installdir("lib"))
        os.mv("Package/" .. conf .. "/MoltenVK/MoltenVK.xcframework/" .. plat:lower() .. "-*/*.a", package:installdir("lib"))
        os.mv("Package/" .. conf .. "/MoltenVKShaderConverter/Tools/*", package:installdir("bin"))
        os.mv("Package/" .. conf .. "/MoltenVKShaderConverter/MoltenVKShaderConverter.xcframework/" .. plat:lower() .. "-*/*.a", package:installdir("lib"))
        os.mv("Package/" .. conf .. "/MoltenVKShaderConverter/include/*.h", package:installdir("include"))
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:has_cfuncs("vkGetDeviceProcAddr", {includes = "vulkan/vulkan_core.h"}))
    end)
