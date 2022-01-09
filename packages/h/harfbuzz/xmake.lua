package("harfbuzz")

    set_homepage("https://harfbuzz.github.io/")
    set_description("HarfBuzz is a text shaping library.")
    set_license("MIT")

    add_urls("https://github.com/harfbuzz/harfbuzz/archive/refs/tags/$(version).tar.gz",
             "https://github.com/harfbuzz/harfbuzz.git")
    add_versions("2.8.1", "b3f17394c5bccee456172b2b30ddec0bb87e9c5df38b4559a973d14ccd04509d")
    add_versions("2.9.0", "bf5d5bad69ee44ff1dd08800c58cb433e9b3bf4dad5d7c6f1dec5d1cf0249d04")
    add_versions("3.0.0", "55f7e36671b8c5569b6438f80efed2fd663298f785ad2819e115b35b5587ef69")
    add_versions("3.1.1", "5283c7f5f1f06ddb5e2e88319f6946ea37d2eb3a574e0f73f6000de8f9aa34e6")

    add_configs("icu", {description = "Enable ICU library unicode functions.", default = false, type = "boolean"})
    add_configs("freetype", {description = "Enable freetype interop helpers.", default = true, type = "boolean"})

    add_deps("meson")
    add_includedirs("include", "include/harfbuzz")
    if is_plat("macosx") then
        add_frameworks("CoreText", "CoreFoundation", "CoreGraphics")
    end
    on_load("windows", "linux", "macosx", function (package)
        if package:config("icu") then
            package:add("deps", "icu4c")
        end
        if package:config("freetype") then
            package:add("deps", "freetype")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        import("package.tools.meson")

        local configs = {"-Dtests=disabled", "-Ddocs=disabled", "-Dbenchmark=disabled", "-Dcairo=disabled", "-Dglib=disabled", "-Dgobject=disabled"}
        if package:is_plat("macosx") then
            table.insert(configs, "-Dcoretext=enabled")
        end
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-Dicu=" .. (package:config("icu") and "enabled" or "disabled"))
        table.insert(configs, "-Dfreetype=" .. (package:config("freetype") and "enabled" or "disabled"))
        local envs = meson.buildenvs(package)
        if package:is_plat("windows") then
            for _, dep in ipairs(package:orderdeps()) do
                local fetchinfo = dep:fetch()
                if fetchinfo then
                    for _, includedir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                        envs.INCLUDE = (envs.INCLUDE or "") .. path.envsep() .. includedir
                    end
                    for _, linkdir in ipairs(fetchinfo.linkdirs) do
                        envs.LIB = (envs.LIB or "") .. path.envsep() .. linkdir
                    end
                end
            end
        end
        meson.install(package, configs, {envs = envs})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("hb_buffer_add_utf8", {includes = "hb.h"}))
    end)
