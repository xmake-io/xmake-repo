package("chaiscript")

    set_kind("library", {headeronly = true})
    set_homepage("http://chaiscript.com")
    set_description("Header-only C++ embedded scripting language loosely based on ECMA script.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/ChaiScript/ChaiScript/archive/$(version).tar.gz",
             "https://github.com/ChaiScript/ChaiScript.git")
    add_versions("v6.1.0", "3ca9ba6434b4f0123b5ab56433e3383b01244d9666c85c06cc116d7c41e8f92a")

    if is_plat("windows") then
        add_cxflags("/bigobj")
    end

    on_install("windows", "linux", "android", "macosx", "iphoneos", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <chaiscript/chaiscript.hpp>
            double function(int i, double j) {
                return i * j;
            }
            static void test() {
                chaiscript::ChaiScript chai;
                chai.add(chaiscript::fun(&function), "function");
                double d = chai.eval<double>("function(3, 4.75);");
            }
        ]]}, {configs = {languages = "c++14"}, includes = "chaiscript/chaiscript.hpp"}))
    end)
