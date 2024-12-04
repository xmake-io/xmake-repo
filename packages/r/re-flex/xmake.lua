package("re-flex")
    set_homepage("https://www.genivia.com/doc/reflex/html")
    set_description("A high-performance C++ regex library and lexical analyzer generator with Unicode support.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/Genivia/RE-flex/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Genivia/RE-flex.git")

    add_versions("v5.0.1", "b74430fe63a6e3e665676d23601e332fcf12714efb798661bf307cb7a230ca4f")
    add_versions("v4.5.0", "30a503087c4ea7c2f81ef8b7f1c54ea10c3f26ab3a372d2c874273ee5e643472")
    add_versions("v4.4.0", "3b34d0c88f91db6b5387355a64a84bfa6464d90fb182aab05c367605db28d2e8")
    add_versions("v4.3.0", "1658c1be9fa95bf948a657d75d2cef0df81b614bc6052284935774d4d8551d95")

    on_install(function (package)
        io.writefile("xmake.lua",[[
            add_rules("mode.debug", "mode.release")
            set_languages("cxx11")
            add_includedirs("include")
            set_encodings("utf-8")
            add_vectorexts("all")

            target("re-flex")
                set_kind("$(kind)")
                add_headerfiles("include/(reflex/*.h)")
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
        import("package.tools.xmake").install(package)
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
