package("guetzli")

    set_homepage("https://github.com/google/guetzli")
    set_description("Perceptual JPEG encoder")

    add_urls("https://github.com/google/guetzli/archive/refs/tags/$(version).tar.gz",
             "https://github.com/google/guetzli.git")

    add_versions("v1.0.1", "e52eb417a5c0fb5a3b08a858c8d10fa797627ada5373e203c196162d6a313697")

    add_deps("libpng")
    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("libpng")
            target("guetzli_lib")
                set_kind("$(kind)")
                add_files("guetzli/*.cc|guetzli")
                add_files("third_party/butteraugli/butteraugli/butteraugli.cc")
                add_packages("libpng")
                add_headerfiles("(guetzli/*.h)")
                add_headerfiles("third_party/butteraugli/(butteraugli/*.h)")
                add_includedirs("third_party/butteraugli", ".")
                set_languages("c99", "c++17")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        import("package.tools.xmake").install(package, {buildir = "xmake_build"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                using namespace guetzli;
                std::string output;
                Params param;
                Process(param, nullptr, "", &output);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "guetzli/processor.h"}))
    end)
