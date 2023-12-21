package("toojpeg")

    set_homepage("https://create.stephan-brumme.com/toojpeg/")
    set_description("A JPEG encoder in a single C++ file")
    set_license("zlib")

    add_urls("https://github.com/stbrumme/toojpeg/archive/refs/tags/toojpeg_v$(version).zip",
             "https://github.com/stbrumme/toojpeg.git")
    add_versions("1.5", "ff2a8a9d89c1ec34328a0f9e09530e98b22df93644ca6c19e005842dd812976b")

    add_configs("shared", {description = "Build share library.", default = false, type = "boolean", readonly = true})

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("c++11")
            target("toojpeg")
                set_kind("static")
                add_files("toojpeg.cpp")
                add_headerfiles("toojpeg.h")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cstdio>
            FILE *f;
            unsigned char pixels[1024*768*3];
            void test() {
                f = fopen("image.jpg", "w");
                auto writeByte = [](unsigned char byte) { fputc(byte, f); };
                TooJpeg::writeJpeg(writeByte, pixels, 1024, 768);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "toojpeg.h"}))
    end)
