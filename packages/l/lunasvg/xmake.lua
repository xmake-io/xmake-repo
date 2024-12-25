package("lunasvg")
    set_homepage("https://github.com/sammycage/lunasvg")
    set_description("LunaSVG - SVG rendering library in C++")
    set_license("MIT")

    add_urls("https://github.com/sammycage/lunasvg/archive/refs/tags/$(version).tar.gz",
             "https://github.com/sammycage/lunasvg.git")

    add_versions("v3.1.0", "2e05791bcc7c30c77efc4fee23557c5c4c9ccd4cf626a3167c0b4a4a316ae2b6")
    add_versions("v3.0.1", "39e3f47d4e40f7992d7958123ca1993ff1a02887539af2af1c638da2855a603c")
    add_versions("v2.4.1", "db9d2134c8c2545694e71e62fb0772a7d089fe53e1ace1e08c2279a89e450534")
    add_versions("v2.4.0", "0682c60501c91d75f4261d9c1a5cd44c2c9da8dba76f8402eab628448c9a4591")
    add_versions("v2.3.9", "088bc9fd1191a004552c65bdcc260989b83da441b0bdaa965e79d984feba88fa")
    add_versions("v2.3.5", "350ff56aa1acdedefe2ad8a4241a9fb8f9b232868adc7bd36dfb3dbdd57e2e93")

    add_deps("cmake")
    add_deps("plutovg")

    add_includedirs("include", "include/lunasvg")

    on_load(function (package)
        local version = package:version()
        if package:gitref() or version:ge("2.4.1") then
            if not package:config("shared") then
                package:add("defines", "LUNASVG_BUILD_STATIC")
            end
        else
            if package:config("shared") then
                package:add("defines", "LUNASVG_SHARED")
            end
        end
    end)

    on_install(function (package)
        io.replace("CMakeLists.txt", "FetchContent_MakeAvailable(plutovg)", "find_package(plutovg)", {plain = true})

        local configs = {"-DLUNASVG_BUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.trycp(path.join(package:buildir(), "lunasvg.pdb"), dir)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <lunasvg.h>
            void test() {
                auto document = lunasvg::Document::loadFromFile("tiger.svg");
                auto bitmap = document->renderToBitmap();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
