package("qjswrapper")
    set_homepage("https://github.com/burdockcascade/qjswrapper")
    set_description("A modern, high-level C++ wrapper library designed to integrate and interact with the QuickJS engine.")
    set_license("MIT")
    set_kind("headeronly")

    add_urls("https://github.com/burdockcascade/qjswrapper/archive/refs/tags/$(version).tar.gz",
             "https://github.com/burdockcascade/qjswrapper.git")

    add_versions("0.1.0", "e38144b0c01cf1e484a0417ef97e7fa8cf307fb8515a3514512cd32605d7c6f4")

    add_deps("quickjs-ng")

    on_install(function (package)
        os.cp("include/qjswrapper.hpp", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({
            test = [[
                void test() {
                    qjs::Engine engine;
                }
            ]]
        }, {configs = {languages = "cxx23"}, includes = "qjswrapper.hpp"}))
    end)
