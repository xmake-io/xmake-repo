package("pcre2")

    set_homepage("https://www.pcre.org/")
    set_description("A Perl Compatible Regular Expressions Library")

    set_urls("https://ftp.pcre.org/pub/pcre/pcre2-$(version).zip",
             "ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre2-$(version).zip")

    add_versions("10.23", "6301a525a8a7e63a5fac0c2fbfa0374d3eb133e511d886771e097e427707094a")
    add_versions("10.30", "3677ce17854fffa68fce6b66442858f48f0de1f537f18439e4bd2771f8b4c7fb")
    add_versions("10.31", "b4b40695a5347a770407d492c1749e35ba3970ca03fe83eb2c35d44343a5a444")

    if is_host("windows") then
        add_deps("cmake")
    end

    add_configs("shared", {description = "Enable shared library.", default = false, type = "boolean"})
    add_configs("jit", {description = "Enable jit.", default = true, type = "boolean"})
    add_configs("bitwidth", {description = "Set the code unit width.", default = "8", values = {"8", "16", "32"}})

    on_load(function (package)
        local bitwidth = package:config("bitwidth") or "8"
        package:add("links", "pcre2-" .. bitwidth)
        package:add("defines", "PCRE2_CODE_UNIT_WIDTH=" .. bitwidth)
        if not package:config("shared") then
            package:add("defines", "PCRE2_STATIC")
        end
    end)

    if is_plat("windows") and winos.version():gt("winxp") then
        on_install("windows", function (package)
            local configs = {}
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            table.insert(configs, "-DPCRE2_SUPPORT_JIT=" .. (package:config("jit") and "ON" or "OFF"))
            local bitwidth = package:config("bitwidth") or "8"
            if bitwidth ~= "8" then
                table.insert(configs, "-DPCRE2_BUILD_PCRE2_8=OFF")
                table.insert(configs, "-DPCRE2_BUILD_PCRE2_" .. bitwidth .. "=ON")
            end
            if package:debug() then
                table.insert(configs, "-DPCRE2_DEBUG=ON")
            end
            import("package.tools.cmake").install(package, configs)
        end)
    end

    on_install("macosx", "linux", function (package)
        local configs = {}
        if package:config("shared") then
            table.insert(configs, "--enable-shared")
        end
        if package:config("jit") then
            table.insert(configs, "--enable-jit")
        end
        local bitwidth = package:config("bitwidth") or "8"
        if bitwidth ~= "8" then
            table.insert(configs, "--disable-pcre2-8")
            table.insert(configs, "--enable-pcre2-" .. bitwidth)
        end
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(import("lib.detect.has_cfuncs")("pcre2_compile", {configs = package:fetch(), includes = "pcre2.h", links = package:get("links")}))
    end)
