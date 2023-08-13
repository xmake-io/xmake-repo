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
    add_versions("4.4.1", "1a95b091a40546a211b6f38a65ccd0950fa5be38d95c77b5c4fa245130b418e1")
    add_versions("5.3.1", "77c8c903f4539b050a6d3a5be79705c7ccf7b1cb66d68152a651486e261edbd2")
    add_versions("6.0.0", "6d753948587db3c7c3ba8cc4f8e6bf83f5c448d2591a9f7ec306467f3a4fe4fa")
    add_versions("7.3.0", "7cefc6cc161e9d5c88210dafc43bc733ca3e383fd3dd4f1e6178f81bd41cfaae")
    add_versions("8.0.0", "a8e8ec6f0befce0bd5345dd741d2f88534685a798002e343a38b7f9b2e00c884")
    add_versions("8.0.1", "d54ca67b6a0bf732b66a343566446d7f93df2bb850133f886c0082fb618a06b2")
    add_versions("8.1.0", "8d544f1b74797b7b4d88f586e3b9202528b3e8c17968d28b7cdde02041bff5a0")
    add_versions("8.1.1", "b16e6bc0fc7e6a218583f40c7d201771f2e3072f85ef6e9217b36c1dc6b2aa25")

    add_configs("icu", {description = "Enable ICU library unicode functions.", default = false, type = "boolean"})
    add_configs("freetype", {description = "Enable freetype interop helpers.", default = true, type = "boolean"})

    if is_plat("android") then
        add_deps("cmake")
    else
        add_deps("meson", "ninja")
        if is_plat("windows") then
            add_deps("pkgconf")
        end
    end
    add_includedirs("include", "include/harfbuzz")
    if is_plat("macosx") then
        add_frameworks("CoreText", "CoreFoundation", "CoreGraphics")
    elseif is_plat("bsd", "android") then
        add_configs("freetype", {description = "Enable freetype interop helpers.", default = false, type = "boolean", readonly = true})
    elseif is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    on_load(function (package)
        if package:config("icu") then
            package:add("deps", "icu4c")
        end
        if package:config("freetype") then
            package:add("deps", "freetype")
        end
    end)

    on_install("android", function (package)
        local configs = {"-DHB_HAVE_GLIB=OFF", "-DHB_HAVE_GOBJECT=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DHB_HAVE_FREETYPE=" .. (package:config("freetype") and "ON" or "OFF"))
        table.insert(configs, "-DHB_HAVE_ICU=" .. (package:config("icu") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_install(function (package)
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
            import("lib.detect.find_tool")
            import("lib.detect.find_program")
            local pkgconf1 = find_tool("pkgconf", {force = true})
            print("pkgconf1", pkgconf)
            
            local pkgconf2 = find_program("pkgconf", {force = true})
            print("pkgconf2", pkgconf)
        
            os.execv("pkgconf --version")
            print(envs)
            print(os.getenv("PATH"))
        end
        meson.install(package, configs, {envs = envs})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("hb_buffer_add_utf8", {includes = "hb.h"}))
    end)
