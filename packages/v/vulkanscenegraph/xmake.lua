package("vulkanscenegraph")
    set_homepage("http://www.vulkanscenegraph.org")
    set_description("Vulkan & C++17 based Scene Graph Project")
    set_license("MIT")

    add_urls("https://github.com/vsg-dev/VulkanSceneGraph/archive/refs/tags/$(version).tar.gz",
             "https://github.com/vsg-dev/VulkanSceneGraph.git")

    add_versions("v1.1.11", "11d2ecaea0f10c717ea90fdd494a4e899d59b847b68dc1a47d1370de89f095e5")
    add_versions("v1.1.10", "b430132ba5454e0616ff5334a7cb9196c0e8f10a925c2106e80a78d6f24ae4b5")
    add_versions("1.0.2", "526acd58d6e3a3bd3c3169996e0616d5c4a01e793dc064e8d20217791743bab5")

    add_configs("max_devices", {description = "Set the maximum number of vk::Device / vsg::Device instances supported.", default = "1"})
    add_configs("instrumentation_level", {description = "Set the instrumentation level for VSG: 0 = off, 1 = coarse, 2 = medium, 3 = fine-grained.", default = "1", values = {"0", "1", "2", "3"}})
    add_configs("shader_compiler", {description = "Enable shader compiler support.", default = false,  type = "boolean"})
    add_configs("windowing", {description = "Enable native windowing support (provides default vsg::Window::create() implementation).", default = true,  type = "boolean"})

    add_deps("cmake", "vulkansdk")   

    on_load(function (package)
        if package:config("shader_compiler") then
            package:add("deps", "glslang")
        end
        if package:is_plat("windows") then
            package:add("defines", "WIN32")
            if package:config("shared") then
                package:add("defines", "VSG_SHARED_LIBRARY")
            end
        end
    end)


    on_install("windows", "macosx", "linux", "android", function (package)
        io.replace("CMakeLists.txt", "vsg_add_target_clobber()", "", {plain = true})
        io.replace("CMakeLists.txt", "vsg_add_target_uninstall()", "", {plain = true})

        local configs = {
            "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"),
            "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"),
            "-DVSG_MAX_DEVICES=" .. package:config("max_devices"),
            "-DVSG_MAX_INSTRUMENTATION_LEVEL=" .. package:config("instrumentation_level"),
            "-DVSG_SUPPORTS_ShaderCompiler=" .. (package:config("shader_compiler") and "1" or "0"),
            "-DVSG_SUPPORTS_Windowing=" .. (package:config("windowing") and "1" or "0")
        }

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int argc, char* argv[]) {
                bool help = false;
                vsg::CommandLine arguments(&argc, argv);
                if (arguments.read("--help")) help = true;


            }
        ]]}, {configs = {languages = "c++17"}, includes = {"vsg/utils/CommandLine.h"}}))
    end)