package("pcre")

    set_homepage("https://www.pcre.org/")
    set_description("A Perl Compatible Regular Expressions Library")

    set_urls("https://ftp.pcre.org/pub/pcre/pcre-$(version).zip",
             "ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-$(version).zip")

    add_versions("8.40", "99e19194fa57d37c38e897d07ecb3366b18e8c395b36c6d555706a7f1df0a5d4")
    add_versions("8.41", "0e914a3a5eb3387cad6ffac591c44b24bc384c4e828643643ebac991b57dfcc5")

    if is_host("windows") then
        add_deps("cmake")
    end

    add_configs("jit", {description = "Enable jit.", default = true, type = "boolean"})
    add_configs("bitwidth", {description = "Set the code unit width.", default = "8", values = {"8", "16", "32"}})

    on_load(function (package)
        local bitwidth = package:config("bitwidth") or "8"
        package:add("links", "pcre" .. (bitwidth ~= "8" and bitwidth or ""))
        if not package:config("shared") then
            package:add("defines", "PCRE_STATIC")
        end
    end)

    on_install("windows", function (package)
        local configs = {}
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

    on_install("macosx", "linux", "mingw@linux,macosx", function (package)
        local configs = {}
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
        else
            table.insert(configs, "--enable-shared=no")
        end
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
