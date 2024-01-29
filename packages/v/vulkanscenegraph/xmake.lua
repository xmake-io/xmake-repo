package("vulkanscenegraph")

    set_homepage("https://vsg-dev.github.io/VulkanSceneGraph/")
    set_description("VulkanSceneGraph (VSG), is a modern, cross platform, high performance scene graph library built upon Vulkan graphics/compute API.")
    set_license("MIT")

    add_urls("https://github.com/vsg-dev/VulkanSceneGraph.git")
    add_urls("https://github.com/vsg-dev/VulkanSceneGraph/archive/refs/tags/$(version).tar.gz", {version = function (version) 
        local prefix = "VulkanSceneGraph-"
        if version:gt("1.0.4") then
            prefix = "v"
        end
         return prefix .. version:gsub("%+", ".")
    end})
    add_versions("1.0.2", "526acd58d6e3a3bd3c3169996e0616d5c4a01e793dc064e8d20217791743bab5")
    add_versions("1.1.0", "ec5e1db9ec4082598b6d56fb5812fdf552e5a6b49792cb80f29bcb8a23fe7cac")

    add_deps("vulkan-headers")
    on_load("windows", function (package)
        package:add("defines", "WIN32")
        if package:config("shared") then
            package:add("defines", "VSG_SHARED_LIBRARY")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        io.replace("CMakeLists.txt", "vsg_add_target_clobber()", "", {plain = true})
        io.replace("CMakeLists.txt", "vsg_add_target_uninstall()", "", {plain = true})
        io.replace("CMakeLists.txt", "set(Vulkan_MIN_VERSION 1.1.70.0)", "", {plain = true})
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int argc, char* argv[]) {
                bool help = false;
                vsg::CommandLine arguments(&argc, argv);
                if (arguments.read("--help")) help = true;
            }
        ]]}, {configs = {languages = "c++17"}, includes = "vsg/utils/CommandLine.h"}))
    end)
