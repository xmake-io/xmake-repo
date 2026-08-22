package("tinycolormap")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/yuki-koyama/tinycolormap")
    set_description("A header-only, single-file library for colormaps written in C++11")
    set_license("MIT")

    add_urls("https://github.com/yuki-koyama/tinycolormap/archive/refs/tags/$(version).tar.gz",
             "https://github.com/yuki-koyama/tinycolormap.git")

    add_versions("v0.8.0", "32790e512cf94342647c899b4748056d3b2c09a801de659d5be743fa6eb9a7af")
    add_versions("v0.7.0", "5e03b6c35c658aa7273ca6fb38ef9df06f885a2429191059c8770d5ff8b65951")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                double value = 0.75;
                auto color = tinycolormap::GetColor(value, tinycolormap::ColormapType::Viridis);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "tinycolormap.hpp"}))
    end)
