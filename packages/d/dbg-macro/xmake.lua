package("dbg-macro")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/sharkdp/dbg-macro")
    set_description("A dbg(…) macro for C++")
    set_license("MIT")

    add_urls("https://github.com/sharkdp/dbg-macro/archive/refs/tags/$(version).tar.gz",
             "https://github.com/sharkdp/dbg-macro.git")
    add_versions("v0.4.0", "e44a1206fbfd1d3dc8ad649f387df479d288b08c80cf2f1239ccb4e26148d781")
    add_versions("v0.5.0", "dac4907aadf39dbd9eac279a214c59ad30af6c0c3d585688242f73cb1a9ce243")

    on_install(function (package)
        os.cp("dbg.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test()
            {
                int a = 1;
                long b = 2;
                dbg(a);
                dbg(b);
                dbg(&a);
            }
        ]]}, {configs = {languages = "c++17"}, includes = { "dbg.h" } }))
    end)
