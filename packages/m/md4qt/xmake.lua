package("md4qt")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/igormironchik/md4qt")
    set_description("Markdown parser for Qt6 or ICU")
    set_license("MIT")

    add_urls("https://github.com/igormironchik/md4qt/archive/refs/tags/$(version).tar.gz",
             "https://github.com/igormironchik/md4qt.git")

    add_versions("2.1.0", "cfbf515adecd798a3f1a4f2e007021b4b31742dd0b36805c273b3b8316fd820d")

    add_configs("qt6", {description = "Use Qt6", default = true, type = "boolean"})
    add_configs("icu", {description = "Use icu", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("qt6core")

    on_load(function (package)
        if package:config("icu") then
            package:add("deps", "icu4c", "uriparser")
        end
    end)

    on_install("windows|x64", "linux|x86_64", "macosx|x86_64", "mingw|x86_64", function (package)
        import("package.tools.cmake").install(package, {
            "-DBUILD_MD4QT_BENCHMARK=OFF",
            "-DBUILD_MD4QT_QT_TESTS=OFF",
            "-DBUILD_MD4QT_STL_TESTS=OFF",
            "-DBUILD_MD2HTML_APP=OFF",
        })
    end)

    on_test(function (package)
        local cxflags
        if package:is_plat("windows") then
            cxflags = {"/Zc:__cplusplus", "/permissive-"}
        else
            cxflags = "-fPIC"
        end
        assert(package:check_cxxsnippets({test = [[
            #define MD4QT_QT_SUPPORT
            #include <md4qt/parser.hpp>
            void test() {
                MD::Parser< MD::QStringTrait > p;
                auto doc = p.parse( QStringLiteral( "your_markdown.md" ) );
            }
        ]]}, {configs = {languages = "c++17", cxflags = cxflags}}))
    end)
