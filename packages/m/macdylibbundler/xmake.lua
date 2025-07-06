package("macdylibbundler")
    set_homepage("https://github.com/auriamg/macdylibbundler")
    set_description("dylibbundler is a small command-line programs that aims to make bundling")
    set_license("MIT")

    add_urls("https://github.com/auriamg/macdylibbundler/archive/refs/tags/$(version).zip",
             "https://github.com/auriamg/macdylibbundler.git")

    add_versions("1.0.5", "d48138fd6766c70097b702d179a657127f9aed3d083051c2d4fce145881a316e")

    on_install("linux", "macosx", "android", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("macdylibbundler")
                set_kind("$(kind)")
                set_languages("c++11")
                add_files("src/*.cpp")
                add_includedirs("src")
                add_headerfiles("src/*.h")]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                collectSubDependencies();
            }
        ]]}, {configs = {languages = "c++11"}, includes = "DylibBundler.h"}))
    end)
