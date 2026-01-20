package("tclap")
    set_kind("library", {headeronly = true})
    set_homepage("https://tclap.sourceforge.net/")
    set_description("Templatized C++ command-line parser library")
    set_license("MIT")

    add_urls("https://github.com/mirror/tclap/archive/refs/tags/$(version).tar.gz",
             "https://git.code.sf.net/p/tclap/code.git")

    add_versions("v1.2.5", "7e87d13734076fa4f626f6144ce9a02717198b3f054341a6886e2107b048b235")

    on_install(function (package)
        os.cp("include/tclap", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <tclap/CmdLine.h>
            void test() {
                TCLAP::CmdLine cmd("Test", ' ', "0.9");
            }
        ]]}, {configs = {languages = "c++98"}}))
    end)
