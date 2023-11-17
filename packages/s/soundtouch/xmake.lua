package("soundtouch")
    set_homepage("https://modplug-xmms.sourceforge.net")
    set_description("SoundTouch Audio Processing Library")
    set_license("LGPL-2.1")

    add_urls("https://www.surina.net/soundtouch/soundtouch-$(version).tar.gz",
             "https://codeberg.org/soundtouch/soundtouch.git")
    add_versions("2.3.2", "3bde8ddbbc3661f04e151f72cf21ca9d8f8c88e265833b65935b8962d12d6b08")

    add_configs("integers_samples", {description = "Use integers instead of floats for samples", default = false, type = "boolean"})
    if is_arch("arm.*") then
        add_configs("neon", {description = "Use ARM Neon SIMD instructions if in ARM CPU", default = true, type = "boolean"})
    end
    add_configs("openmp", {description = "Use parallel multicore calculation through OpenMP", default = false, type = "boolean"})
    add_configs("dll", {description = "Build SoundTouchDLL C wrapper library", default = false, type = "boolean"})

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DSOUNDSTRETCH=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DINTEGER_SAMPLES=" .. (package:config("integers_samples") and "ON" or "OFF"))
        table.insert(configs, "-DSOUNDTOUCH_DLL=" .. (package:config("dll") and "ON" or "OFF"))
        table.insert(configs, "-DOPENMP=" .. (package:config("openmp") and "ON" or "OFF"))
        if package:is_arch("arm.*") then
            table.insert(configs, "-DNEON=" .. (package:config("neon") and "ON" or "OFF"))
        elseif package:is_plat("wasm") then
            io.replace("CMakeLists.txt", "-Ofast", "", {plain = true})
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <soundtouch/SoundTouch.h>
            void test() {
                soundtouch::SoundTouch sound;
            }
        ]]}))
    end)
