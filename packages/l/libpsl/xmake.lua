package("libpsl")

    set_homepage("https://github.com/rockdaboot/libpsl")
    set_description("C library to handle the Public Suffix List")
    set_license("MIT")

    add_urls("https://github.com/rockdaboot/libpsl/releases/download/$(version)/libpsl-$(version).tar.gz")
    add_versions("0.21.1", "ac6ce1e1fbd4d0254c4ddb9d37f1fa99dec83619c1253328155206b896210d4c")

    add_deps("meson", "ninja")
    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32")
    end
    on_load("windows", function (package)
        if not package:config("shared") then
            package:add("defines", "PSL_STATIC")
        end
    end)

    on_install("windows", "macosx", "linux", "mingw", function (package)
        io.replace("meson.build", "subdir('tests')", "", {plain = true})
        io.replace("meson.build", "subdir('fuzz')", "", {plain = true})
        if package:is_plat("windows") and not package:config("shared") then
            io.replace("tools/meson.build", "'-DHAVE_CONFIG_H'", "'-DHAVE_CONFIG_H','-DPSL_STATIC'", {plain = true})
        end
        local configs = {"-Druntime=no", "-Dbuiltin=no"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("psl_suffix_count", {includes = "libpsl.h"}))
    end)
