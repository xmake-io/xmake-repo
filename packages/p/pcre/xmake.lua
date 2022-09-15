package("pcre")

    set_homepage("https://www.pcre.org/")
    set_description("A Perl Compatible Regular Expressions Library")

    set_urls("https://github.com/xmake-mirror/pcre/releases/download/$(version)/pcre-$(version).tar.bz2")
    add_versions("8.45", "4dae6fdcd2bb0bb6c37b5f97c33c2be954da743985369cddac3546e3218bffb8")

    if is_plat("windows") then
        add_deps("cmake")
    end
    add_deps("zlib")

    add_configs("jit", {description = "Enable jit.", default = true, type = "boolean"})
    add_configs("bitwidth", {description = "Set the code unit width.", default = "8", values = {"8", "16", "32"}})

    on_load("windows", "mingw", function (package)
        if not package:config("shared") then
            package:add("defines", "PCRE_STATIC")
        end
    end)

    on_install("windows", function (package)
        local configs = {"-DPCRE_BUILD_TESTS=OFF"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DPCRE_SUPPORT_JIT=" .. (package:config("jit") and "ON" or "OFF"))
        local bitwidth = package:config("bitwidth") or "8"
        if bitwidth ~= "8" then
            table.insert(configs, "-DPCRE_BUILD_PCRE8=OFF")
            table.insert(configs, "-DPCRE_BUILD_PCRE" .. bitwidth .. "=ON")
        end
        if package:debug() then
            table.insert(configs, "-DPCRE_DEBUG=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_install("macosx", "linux", "mingw", "cross", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:config("jit") then
            table.insert(configs, "--enable-jit")
        end
        local bitwidth = package:config("bitwidth") or "8"
        if bitwidth ~= "8" then
            table.insert(configs, "--disable-pcre8")
            table.insert(configs, "--enable-pcre" .. bitwidth)
        end
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        local bitwidth = package:config("bitwidth") or "8"
        local testfunc = string.format("pcre%s_compile", bitwidth ~= "8" and bitwidth or "")
        assert(package:has_cfuncs(testfunc, {includes = "pcre.h"}))
    end)
