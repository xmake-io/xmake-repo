package("reflex")
    set_description("The reflex package")

    add_urls("https://github.com/Genivia/RE-flex/archive/refs/tags/v$(version).tar.gz","https://github.com/Genivia/RE-flex.git")
    add_versions("3.5.1", "e08ed24a6799a6976f6e32312be1ee059b4b6b55f8af3b433a3016d63250c0e4")
    add_versions("4.3.0", "1658c1be9fa95bf948a657d75d2cef0df81b614bc6052284935774d4d8551d95")

    add_includedirs("include")

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_install(function (package)
        io.writefile("xmake.lua",[[
set_languages("cxx11")

target("ReflexLib")
    set_kind("shared")
    add_includedirs("include")
    add_headerfiles("include/reflex/*.h", {prefixdir = "reflex"})
    add_files("lib/*.cpp")
    add_files("unicode/*.cpp")
    add_vectorexts("all")
target_end()

target("ReflexLibStatic")
    set_kind("static")
    add_includedirs("include")
    add_headerfiles("include/reflex/*.h", {prefixdir = "reflex"})
    add_files("lib/*.cpp")
    add_files("unicode/*.cpp")
    add_vectorexts("all")
target_end()

target("Reflex")
    set_kind("binary")
    add_includedirs("include")
    add_files("src/*.cpp")
    add_deps("ReflexLibStatic")
    add_vectorexts("all")
target_end()
        ]])
        local configs = {}
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <reflex/matcher.h>
            void test()
            {
                reflex::Matcher matcher("\w+","114 514 1919 810");
            }
        ]]}, {configs = {languages = "cxx11"}}))
    end)
package_end()
