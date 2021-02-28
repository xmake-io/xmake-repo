package("tclap")
    set_homepage("https://sourceforge.net/projects/tclap/")
    set_description("This is a simple templatized C++ library for parsing command line arguments.")
    set_license("MIT")

    set_urls("https://netcologne.dl.sourceforge.net/project/tclap/tclap-$(version).tar.bz2")
    add_versions("1.4.0-rc1", "33e18c7828f76a9e5f2a00afe575156520e383693059ca9bc34ff562927e20c6")

    -- NOTE it could be useful to patch CMakeLists.txt
    -- in order to avoid building examples

    -- python3 is required by the tests module
    add_deps("cmake", "python 3.*")

    on_install(function (package)
        -- We don't want to build the doc
        local configs = {"-DBUILD_DOC=false"}
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <tclap/CmdLine.h>
            void test() {
                TCLAP::CmdLine cmd("Test", ' ', "0.9");
            }
        ]]}, {configs = {languages = "c++98"}}))
    end)