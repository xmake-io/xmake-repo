package("tvision")
    set_homepage("https://github.com/magiblot/tvision")
    set_description("A modern port of Turbo Vision 2.0, the classical framework for text-based user interfaces. Now cross-platform and with Unicode support.")
    set_license("MIT")

    add_urls("https://github.com/magiblot/tvision.git")

    add_versions("2025.10.31", "423aeb568a181ffebb3695859654385950588a93")

    add_patches("2025.10.31", "patches/2025.10.31/find-ncurses.patch", "1215d09be45a8c401bc64bb209be4da25f232ae720437e2da496e94d5aa649fb")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    elseif is_plat("linux", "cross") then
        add_configs("gpm", {description = "Enable linking to libgpm", default = true, type = "boolean"})
    end

    add_deps("cmake")

    if is_plat("windows") then
        add_syslinks("kernel32", "user32")
    end

    if not is_plat("windows", "mingw") then
        add_deps("ncurses")
    end

    on_load("linux", "cross", function (package)
        if package:config("gpm") then
            package:add("deps", "gpm")
        end
    end)

    on_install("!wasm and !iphoneos and (!android or android@!windows)", function (package)
        if not package:is_plat("windows") then
            io.replace("source/CMakeLists.txt", "add_library(${PROJECT_NAME} STATIC ${TVSOURCE})", "add_library(${PROJECT_NAME} ${TVSOURCE})", {plain = true})
        end
        local configs = {
            "-DTV_BUILD_EXAMPLES=OFF",
            "-DTV_BUILD_TESTS=OFF"
        }
        table.insert(configs, "-DTV_BUILD_USING_GPM=" .. (package:config("gpm") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            #include <vector>
            #include <string>
            #include <utility>
            #include <type_traits>
            #include <algorithm>
            #define Uses_TRect
            #define Uses_TWindow
            #include <tvision/tv.h>
            void test() {
                short number = 1;
                TWindow window(TRect(0, 0, 0, 0), nullptr, number);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
