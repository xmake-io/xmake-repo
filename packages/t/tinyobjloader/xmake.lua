package("tinyobjloader")
    set_homepage("https://github.com/tinyobjloader/tinyobjloader")
    set_description("Tiny but powerful single file wavefront obj loader")
    set_license("MIT")

    add_urls("https://github.com/tinyobjloader/tinyobjloader/archive/$(version).tar.gz")
    add_urls("https://github.com/tinyobjloader/tinyobjloader.git")
    add_versions("v1.0.7", "b9d08b675ba54b9cb00ffc99eaba7616d0f7e6f6b8947a7e118474e97d942129")
    add_versions("v2.0.0rc10", "e1bc2e5547b562d33ca4a90b581717984a70d58113d83208dbc97c82e137b9fe")
    add_versions("v2.0.0rc13", "0feb92b838f8ce4aa6eb0ccc32dff30cb64a891e0ec3bde837fca49c78d44334")

    add_configs("double", {description = "Use double precision floating numbers.", default = false, type = "boolean"})
    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    on_load(function (package)
        if package:config("double") then
            package:add("defines", "TINYOBJLOADER_USE_DOUBLE")
        end
    end)

    on_install(function (package)
        io.writefile("xmake.lua", string.format([[
            add_rules("mode.debug", "mode.release")
            add_rules("utils.install.cmake_importfiles")
            target("tinyobjloader")
                set_kind("$(kind)")
                %s
                add_files("tiny_obj_loader.cc")
                add_headerfiles("tiny_obj_loader.h")
        ]], package:config("double") and "add_defines(\"TINYOBJLOADER_USE_DOUBLE\")" or ""))
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <vector>
            void test() {
                tinyobj::attrib_t attrib;
                std::vector<tinyobj::shape_t> shapes;
                std::vector<tinyobj::material_t> materials;
            }
        ]]}, {configs = {languages = "c++11"}, includes = "tiny_obj_loader.h"}))
    end)
