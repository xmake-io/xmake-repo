package("apr")
    set_homepage("https://github.com/apache/apr")
    set_description("Mirror of Apache Portable Runtime")
    set_license("Apache-2.0")

    add_urls("https://github.com/apache/apr.git")
    add_versions("2022.05.24", "8e66e54e9e0c1c54c8eaea74f2aeec810a5c8494")

    on_install("linux", "macosx", "windows", function (package)
        os.vrunv("sh", {"./buildconf"})
        if package:is_plat("macosx", "linux") then 
            local configs = {"--prefix=" .. package:installdir()}
            os.vrunv("./configure", configs)
            import("package.tools.make").install(package)
        elseif package:is_plat("windows") then
            local configs = {"-f", "Makefile.win", "PREFIX=" .. package:installdir()}
            import("package.tools.nmake").install(package, configs)
        end
        os.mv(package:installdir("include/apr-2/*"), package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("apr_date_checkmask", {includes = "apr_date.h"}))
    end)
