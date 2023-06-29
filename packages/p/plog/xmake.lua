package("plog")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/SergiusTheBest/plog")
    set_description("Portable, simple and extensible C++ logging library")
    set_license("MIT")

    add_urls("https://github.com/SergiusTheBest/plog/archive/refs/tags/$(version).tar.gz",
             "https://github.com/SergiusTheBest/plog.git")
    add_versions("1.1.9", "058315b9ec9611b659337d4333519ab4783fad3f2f23b1cc7bb84d977ea38055")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <plog/Log.h> // Step1: include the headers
            #include "plog/Initializers/RollingFileInitializer.h"

            void test()
            {
                plog::init(plog::debug, "Hello.txt"); // Step2: initialize the logger
            }
        ]]}))
    end)
