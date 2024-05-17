package("re-flex")
    set_homepage("https://www.genivia.com/doc/reflex/html")
    set_description("A high-performance C++ regex library and lexical analyzer generator with Unicode support. Extends Flex++ with Unicode support, indent/dedent anchors, lazy quantifiers, functions for lex and syntax error reporting and more. Seamlessly integrates with Bison and other parsers.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/Genivia/RE-flex/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Genivia/RE-flex.git")

    add_versions("v4.3.0", "1658c1be9fa95bf948a657d75d2cef0df81b614bc6052284935774d4d8551d95")

    on_install(function (package)
        io.writefile("xmake.lua",[[
            add_rules("mode.debug", "mode.release")
            set_languages("cxx11")
            add_includedirs("include")
            set_encodings("utf-8")

            option("vectorexts")
                set_default(false)
                set_showmenu(true)
                add_vectorexts("all")
            option_end()

            target("re-flex")
                set_kind("$(kind)")
                add_headerfiles("include/reflex/*.h", {prefixdir = "reflex"})
                add_files("lib/*.cpp")
                add_files("unicode/*.cpp")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end

            target("reflex")
                set_kind("binary")
                add_files("src/*.cpp")
                add_deps("re-flex")
        ]])
        import("package.tools.xmake").install(package, configs)
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <reflex/matcher.h>
            void test() {
                reflex::Matcher matcher("\w+","114 514 1919 810");
            }
        ]]}, {configs = {languages = "cxx11"}}))
    end)
