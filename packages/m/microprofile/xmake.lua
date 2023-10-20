package("microprofile")
    set_homepage("https://github.com/jonasmr/microprofile")
    set_description("microprofile is an embeddable profiler")
    set_license("Unlicense")

    add_urls("https://github.com/jonasmr/microprofile/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jonasmr/microprofile.git")

    add_versions("v4.0", "59cd3ee7afd3ce5cfeb7599db62ccc0611818985a8e649353bec157122902a5c")

    add_configs("config_file", {description = "Use user provided configuration in microprofile.config.h file.", default = false, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32", "advapi32", "shell32")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    end

    add_deps("cmake")
    add_deps("stb")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DMICROPROFILE_USE_CONFIG_FILE=" .. (package:config("config_file") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {packagedeps = "stb"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("MicroProfileFlip", {includes = "microprofile.h"}))
    end)
