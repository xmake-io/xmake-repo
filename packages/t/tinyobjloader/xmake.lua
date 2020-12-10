package("tinyobjloader")

    set_homepage("https://github.com/tinyobjloader/tinyobjloader")
    set_description("Tiny but powerful single file wavefront obj loader")
    set_license("MIT")

    add_urls("https://github.com/tinyobjloader/tinyobjloader/archive/v$(version).tar.gz",
             "https://github.com/tinyobjloader/tinyobjloader.git")
    add_versions("1.0.7", "b9d08b675ba54b9cb00ffc99eaba7616d0f7e6f6b8947a7e118474e97d942129")

    add_configs("double", {description = "Use double precision floating numbers.", default = false, type = "boolean"})

    on_install("macosx", "linux", "windows", "mingw", "android", "iphoneos", function (package)
        local kind = package:config("shared") and "shared" or "static"
        io.writefile("xmake.lua", string.format([[
            add_rules("mode.debug", "mode.release")
            target("tinyobjloader")
                set_kind("%s")
                %s
                add_files("tiny_obj_loader.cc")
                add_headerfiles("tiny_obj_loader.h")
        ]], kind, (package:config("double") and "add_defines(\"TINYOBJLOADER_USE_DOUBLE\")" or "")))
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
