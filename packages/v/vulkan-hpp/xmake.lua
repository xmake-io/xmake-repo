package("vulkan-hpp")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/KhronosGroup/Vulkan-Hpp/")
    set_description("Open-Source Vulkan C++ API")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/Vulkan-Hpp.git")

    -- when adding a new sdk version, please ensure vulkan-headers, vulkan-hpp, vulkan-loader, vulkan-tools, vulkan-validationlayers, vulkan-utility-libraries, spirv-headers, spirv-reflect, spirv-tools, glslang and volk packages are updated simultaneously
    add_versions("v1.4.335", "9d55db6621613adf9ccea21dbc853fbd27ea2924")
    add_versions("v1.4.309", "16da8bd29e5d0b921c92d406d194759c0df6a2b8")
    add_versions("v1.2.180", "bfa6d4765212505c8241a44b97dc5a9ce3aa2969")
    add_versions("v1.2.189", "58ff1da4c03f5f124eb835f41a9dd8fe3c2e8087")
    add_versions("v1.2.198", "d8c9f4f0eee6972622a1c3aabab5ed558d37c1c0")
    add_versions("v1.3.231", "ef609a2f77dd1756e672712f264e76b64acdba61")
    add_versions("v1.3.236", "4848fc8e6a923757fd451e52b992dfac48e30814")
    add_versions("v1.3.240", "83adc3fa57b5d5a75ddfb2ce2a0f7fb3abe4bb9c")
    add_versions("v1.3.244", "1bd3877dcc7f3fbf5a43e4d2f0fcc4ebadf6af85")
    add_versions("v1.3.254", "9f89f760a661ff5d7e1e5cc93de13eb4026307b5")
    add_versions("v1.3.261", "3d27c1736a8d520f4d577d9d41566ce1b1fc346e")
    add_versions("v1.3.268", "d2134fefe22279595aee73752099022222468a60")
    add_versions("v1.3.272", "e621db07719c0c1c738ad39ef400737a750bb23a")
    add_versions("v1.3.275", "1a24b015830c116632a0723f3ccfd1f06009ce12")
    add_versions("v1.3.276", "d4b36b82236e052a5e6e4cea5fe7967d5b565ebc")
    add_versions("v1.3.277", "c5c1994f79298543af93d7956b654bdefdfbdd26")
    add_versions("v1.3.278", "29723f90a127ff08d9099855378162f04b4ffddd")
    add_versions("v1.3.279", "6fb8def27290f8b87d7835457a9c68190aed9a9a")
    add_versions("v1.3.280", "e35acfe75215116029298aebf681170559a4fe6a")
    add_versions("v1.3.281", "88d508b32f207ba85b37fe22fe3732322d1c248d")
    add_versions("v1.3.282", "4bf2835dd1a530291cd2b340a58dd7e369d5c86c")
    add_versions("v1.3.283", "2fbc146feefa43b8201af4b01eb3570110f9fa32")
    add_versions("v1.3.290", "e3b0737d57e81875361bf1943f083eac902dacb7")

    add_configs("modules", {description = "Build with C++20 modules support.", default = false, type = "boolean"})

    on_load(function (package)
        if not package:config("modules") then
            package:add("deps", "cmake")
            if package:is_plat("linux") then
                package:add("extsources", "pacman::vulkan-headers")
            end
        end
    end)


    on_install("windows|x86", "windows|x64", "linux", "macosx", "mingw", "android", "iphoneos", function (package)
        local arch_prev
        local plat_prev
        if (package:is_plat("mingw") or package:is_cross()) and package.plat_set then
            arch_prev = package:arch()
            plat_prev = package:plat()
            package:plat_set(os.host())
            package:arch_set(os.arch())
        end
        io.replace("CMakeLists.txt", "-Werror", "", {plain = true})
        io.replace("CMakeLists.txt", "/WX", "", {plain = true})
        import("package.tools.cmake").build(package, {builddir = "build"})
        if arch_prev and plat_prev then
            package:plat_set(plat_prev)
            package:arch_set(arch_prev)
        end
        os.mkdir("build")
        if is_host("windows") then
            os.cp(path.join("**", "VulkanHppGenerator.exe"), "build")
        else
            os.cp(path.join("**", "VulkanHppGenerator"), "build")
        end
        os.runv(path.join("build", "VulkanHppGenerator"))
        if not package:config("modules") then
            os.cp("Vulkan-Headers/include", package:installdir())
            os.cp("vulkan/*.hpp", package:installdir(path.join("include", "vulkan")))
        else
            io.writefile("xmake.lua", [[ 
                target("vulkan-hpp")
                    set_kind("static")
                    set_languages("c++20")
                    add_headerfiles("Vulkan-Headers/include/(**.h)")
                    add_headerfiles("Vulkan/(**.h)")
                    add_headerfiles("Vulkan-Headers/include/(**.hpp)")
                    add_headerfiles("Vulkan/(**.hpp)")
                    add_includedirs("Vulkan")
                    add_includedirs("Vulkan-Headers/include")
                    add_files("Vulkan/vulkan.cppm", {public = true})
            ]])
            local configs = {}
            import("package.tools.xmake").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                vk::ApplicationInfo ai;
                ai.pApplicationName = "Test";
                ai.applicationVersion = VK_MAKE_API_VERSION(1,0,0,0);
                ai.pEngineName = "Test";
                ai.engineVersion = VK_MAKE_API_VERSION(1,0,0,0);
                ai.apiVersion = VK_API_VERSION_1_0;
            }
        ]]}, {includes = "vulkan/vulkan.hpp", configs = {languages = "c++14"} }))
    end)
