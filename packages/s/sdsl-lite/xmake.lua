package("sdsl-lite")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/xxsds/sdsl-lite")
    set_description("Succinct Data Structure Library 3.0")

    add_urls("https://github.com/xxsds/sdsl-lite/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xxsds/sdsl-lite.git")

    add_versions("v3.0.3", "7b3281139f7a6c38049e967dcf1ca1d0cc9b65e62153c2ea163d2c8077dd864b")

    add_configs("cereal", {description = "support for serialisation via cereal", default = false, type = "boolean"})

    on_load(function (package)
        if package:config("cereal") then
            package:add("deps", "cereal >=1.3.2")
            package:add("defines", "SDSL_CEREAL=1")
        end
    end)

    on_install("linux", "macosx", "bsd", "android", "iphoneos", "cross", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <sdsl/construct.hpp>
            void test() {
                sdsl::memory_monitor::start();
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
