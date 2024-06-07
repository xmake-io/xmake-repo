package("agg")

    set_homepage("https://agg.sourceforge.net/antigrain.com/index.html")
    set_description("Anti-Grain Geometry: A High Quality Rendering Engine for C++")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/aggeom/agg-2.6/archive/refs/tags/agg-$(version).zip",
             "https://github.com/aggeom/agg-2.6.git")
    add_versions("2.7.1", "d7b86cdf55282e798aba43194a87705ad30ba950b5723144524e08fe8477db80")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    add_configs("freetype", {description = "Use Freetype library.", default = false, type = "boolean", readonly = true})

    add_deps("cmake")
    if is_plat("macosx", "linux") then
        add_deps("libx11", "libxext")
    end
    add_links("aggctrl", "aggplatform", "agg")
    on_load("windows", "macosx", "linux", "mingw", function (package)
        if package:config("freetype") then
            package:add("deps", "freetype")
        end
    end)

    on_install("windows", "macosx", "linux", "mingw", function (package)
        io.replace("src/platform/CMakeLists.txt", "IF(APPLE)", "IF(FALSE)", {plain = true})
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-Dagg_USE_FREETYPE=" .. (package:config("freetype") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                agg::rasterizer_scanline_aa<> ras;
                ras.reset();
            }
        ]]}, {configs = {languages = "c++11"}, includes = "agg/agg_rasterizer_scanline_aa.h"}))
    end)
