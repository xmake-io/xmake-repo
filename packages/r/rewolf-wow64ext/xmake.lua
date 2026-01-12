package("rewolf-wow64ext")
    set_homepage("https://github.com/rwfpl/rewolf-wow64ext")
    set_description("Helper library for x86 programs that runs under WOW64 layer on x64 versions of Microsoft Windows operating systems.")

    add_urls("https://github.com/rwfpl/rewolf-wow64ext/archive/refs/tags/$(version).tar.gz",
             "https://github.com/rwfpl/rewolf-wow64ext.git")

    add_versions("v1.0.0.9", "d74cd5353ec4f565c61302cf667f4319d2efb554a76cf83b216f8a8a32c058f6")

    on_install("windows", "mingw", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("rewolf-wow64ext")
                set_kind("$(kind)")
                set_languages("c++11")

                add_defines("WOW64EXT_EXPORTS")

                add_files("src/wow64ext.cpp")
                add_files("src/wow64ext.rc")

                add_headerfiles("src/(*.h)")

                add_includedirs("src")

                if is_plat("windows") then
                    add_ldflags("/subsystem:windows")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto handle = GetModuleHandle64(L"user32.dll");
            }
        ]]}, {configs = {languages = "c++11"}, includes = "wow64ext.h"}))
    end)
