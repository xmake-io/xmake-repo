package("iowow")
    set_homepage("https://iowow.softmotions.com")
    set_description("A C utility library and persistent key/value storage engine")
    set_license("MIT")

    add_urls("https://github.com/Softmotions/iowow/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Softmotions/iowow.git")

    add_versions("v1.4.18", "ef4ee56dd77ce326fff25b6f41e7d78303322cca3f11cf5683ce9abfda34faf9")
    add_versions("v1.4.17", "13a851026dbc1f31583fba96986e86e94a7554f9e7d38aa12a9ea5dbebdf328b")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_install("linux", "macosx", "bsd", "cross", function (package)
        io.replace("src/utils/sort_r.h", "defined __FreeBSD__ ||", "", {plain = true})
        local configs = {"-DBUILD_EXAMPLES=OFF", "-DPACKAGE_TGZ=OFF", "-DPACKAGE_ZIP=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DASAN=" .. (package:config("asan") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("iwkv_init", {includes = "iowow/iwkv.h"}))
    end)
