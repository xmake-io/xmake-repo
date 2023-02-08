package("lunasvg")

    set_homepage("https://github.com/sammycage/lunasvg")
    set_description("LunaSVG - SVG rendering library in C++")
    set_license("MIT")

    add_urls("https://github.com/sammycage/lunasvg/archive/refs/tags/$(version).tar.gz",
             "https://github.com/sammycage/lunasvg.git")
    add_versions("v2.3.5", "350ff56aa1acdedefe2ad8a4241a9fb8f9b232868adc7bd36dfb3dbdd57e2e93")

    add_deps("cmake")
    on_load("windows", function (package)
        if package:config("shared") then
            package:add("defines", "LUNASVG_SHARED")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
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
