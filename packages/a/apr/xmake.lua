package("apr")
    set_homepage("https://github.com/apache/apr")
    set_description("Mirror of Apache Portable Runtime")
    set_license("Apache-2.0")

    add_urls("https://github.com/apache/apr/archive/refs/tags/$(version).tar.gz",
             "https://github.com/apache/apr.git")
    add_versions("1.7.0", "a7e2c5e6d60f6c7b1611b31a2f914a3e58f44eded5b064f0bae43ff30b16a4e6")

    on_load(function (package)
        if package:is_plat("macosx", "linux") then
            package:add("deps", "autoconf", "libtool")
        end
    end)

    on_install("linux", "macosx", "windows", function (package)
        if package:is_plat("macosx", "linux") then 
            os.vrunv("sh", {"./buildconf"})
            local configs = {"--prefix=" .. package:installdir()}
            os.vrunv("./configure", configs)
            import("package.tools.make").install(package)
        elseif package:is_plat("windows") then
            local configs = {"-f", "Makefile.win"}
            import("package.tools.nmake").install(package, configs)
            table.insert(configs, "PREFIX=" .. package:installdir(), "install")
            import("package.tools.nmake").install(package, configs)
        end
        os.mv(package:installdir("include/apr-2/*"), package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("apr_date_checkmask", {includes = "apr_date.h"}))
    end)
