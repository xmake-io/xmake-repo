package("lunasvg")
    set_homepage("https://github.com/sammycage/lunasvg")
    set_description("LunaSVG - SVG rendering library in C++")
    set_license("MIT")

    add_urls("https://github.com/sammycage/lunasvg/archive/refs/tags/$(version).tar.gz",
             "https://github.com/sammycage/lunasvg.git")
    add_versions("v2.4.0", "0682c60501c91d75f4261d9c1a5cd44c2c9da8dba76f8402eab628448c9a4591")
    add_versions("v2.3.9", "088bc9fd1191a004552c65bdcc260989b83da441b0bdaa965e79d984feba88fa")
    add_versions("v2.3.5", "350ff56aa1acdedefe2ad8a4241a9fb8f9b232868adc7bd36dfb3dbdd57e2e93")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "LUNASVG_SHARED")
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <lunasvg.h>
            void test() {
                auto document = lunasvg::Document::loadFromFile("tiger.svg");
                auto bitmap = document->renderToBitmap();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
