package("lcms")
    set_homepage("https://www.littlecms.com/")
    set_description("A free, open source, CMM engine. It provides fast transforms between ICC profiles.")
    set_license("MIT")

    add_urls("https://github.com/mm2/Little-CMS/archive/refs/tags/lcms$(version).tar.gz")
    add_urls("https://github.com/mm2/Little-CMS.git", {alias = "git"})

    add_versions("2.17", "6e6f6411db50e85ae8ff7777f01b2da0614aac13b7b9fcbea66dc56a1bc71418")

    add_versions("git:2.18", "lcms2.18rc_1")

    add_patches("2.17", "https://github.com/mm2/Little-CMS/commit/1723db795a477de2b010db7a53b2d159ab94c3fa.diff",
                        "5f47d872f0439ec340e6f59089abbd6ea579539f85a31634787dfbbd9c0bb8aa")

    add_deps("meson", "ninja")

    add_configs("jpeg", {description = "Use JPEG", default = false, type = "boolean"})
    add_configs("tiff", {description = "Use LibTiff", default = false, type = "boolean"})

    add_configs("utils", {description = "Build the utils", default = false, type = "boolean"})
    add_configs("fastfloat", {description = "Build and install the fast float plugin, use only if GPL 3.0 is acceptable", default = false, type = "boolean"})
    add_configs("threaded", {description = "Build and install the multi threaded plugin, use only if GPL 3.0 is acceptable", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "m")
    elseif is_plat("wasm") then
        add_syslinks("pthread")
        add_ldflags("-s USE_PTHREADS=1")
        add_cxflags("-pthread")
    end

    on_load(function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "CMS_DLL")
        end
        if package:config("jpeg") then
            package:add("deps", "libjpeg")
        end
        if package:config("tiff") then
            package:add("deps", "libtiff")
        end
    end)

    on_install(function (package)
        local configs = {}
        if package:is_plat("wasm") and package:config("shared") then
            table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
            table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))

            if package:config("jpeg") then
                table.insert(configs, "--with-jpeg=" .. package:dep("libjpeg"):installdir())
            end
            if package:config("tiff") then
                table.insert(configs, "--with-tiff=" .. package:dep("libtiff"):installdir())
            end

            if package:config("fastfloat") then
                table.insert(configs, "--with-fastfloat")
            end
            if package:config("threaded") then
                table.insert(configs, "--with-threaded")
            end

            if package:config("pic") ~= false then
                table.insert(configs, "--with-pic")
            end
            if package:debug() then
                table.insert(configs, "--enable-debug")
            end

            import("package.tools.autoconf").install(package, configs)
        else
            table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))

            table.insert(configs, "-Djpeg=" .. (package:config("jpeg") and "enabled" or "disabled"))
            table.insert(configs, "-Dtiff=" .. (package:config("tiff") and "enabled" or "disabled"))

            table.insert(configs, "-Dutils=" .. (package:config("utils") and "true" or "false"))
            table.insert(configs, "-Dfastfloat=" .. (package:config("fastfloat") and "true" or "false"))
            table.insert(configs, "-Dthreaded=" .. (package:config("threaded") and "true" or "false"))
        
            import("package.tools.meson").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("cmsXYZ2xyY", {includes = "lcms2.h"}))
    end)
