package("vulkanscenegraph")

    set_homepage("https://vsg-dev.github.io/VulkanSceneGraph/")
    set_description("VulkanSceneGraph (VSG), is a modern, cross platform, high performance scene graph library built upon Vulkan graphics/compute API.")
    set_license("MIT")

    add_urls("https://github.com/vsg-dev/VulkanSceneGraph/archive/refs/tags/VulkanSceneGraph-$(version).tar.gz",
             "https://github.com/vsg-dev/VulkanSceneGraph.git")
    add_versions("1.0.2", "526acd58d6e3a3bd3c3169996e0616d5c4a01e793dc064e8d20217791743bab5")
    add_versions("1.0.3", "84aa1d445ecdd2702843f8f01e760d4db32c2ab3fe8c5d6122f8a83b67a50e36")

    add_deps("cmake", "vulkansdk")
    on_load("windows", function (package)
        package:add("defines", "WIN32")
        if package:config("shared") then
            package:add("defines", "VSG_SHARED_LIBRARY")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        io.replace("CMakeLists.txt", "vsg_add_target_clobber()", "", {plain = true})
        io.replace("CMakeLists.txt", "vsg_add_target_uninstall()", "", {plain = true})
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
