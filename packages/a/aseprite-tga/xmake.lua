package("aseprite-tga")

    set_homepage("https://github.com/aseprite/tga")
    set_description("C++ library to read/write Truevision TGA/TARGA files")
    set_license("MIT")

    set_urls("https://github.com/aseprite/tga.git")
    add_versions("2023.6.2", "d537510d98bc9706675746d132fa460639254a78")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("aseprite-tga")
                set_kind("$(kind)")
                add_files("*.cpp")
                add_headerfiles("tga.h")
                set_languages("c++11")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cstdio>

            void test() {
                FILE* f = std::fopen("img.tga", "rb");
                tga::StdioFileInterface file(f);
                tga::Decoder decoder(&file);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "tga.h"}))
    end)
