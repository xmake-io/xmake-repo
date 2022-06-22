package("apr")
    set_homepage("https://github.com/apache/apr")
    set_description("Mirror of Apache Portable Runtime")
    set_license("Apache-2.0")

    add_urls("https://github.com/apache/apr/archive/refs/tags/$(version).tar.gz",
             "https://github.com/apache/apr.git")
    add_versions("1.7.0", "a7e2c5e6d60f6c7b1611b31a2f914a3e58f44eded5b064f0bae43ff30b16a4e6")

    if is_plat("macosx", "linux") then 
        add_deps("autoconf", "libtool", "python")
    end
    
    on_install("linux", "macosx", "windows", function (package)
        if package:is_plat("linux") then 
            os.vrunv("sh", {"./buildconf"})
            os.vrunv("./configure", {"--prefix=" .. package:installdir()})
            import("package.tools.make").install(package)
        elseif package:is_plat("macosx") then 
            os.exec("sed -i -e 's/#error .* pid_t/#define APR_PID_T_FMT \"d\"/' configure.in")
            os.vrunv("sh", {"./buildconf"})
            os.exec("./configure CFLAGS=-DAPR_IOVEC_DEFINED --prefix=" .. package:installdir())
            import("package.tools.make").install(package)
        elseif package:is_plat("windows") then
            local configs = {"-f", "Makefile.win", "PREFIX=" .. package:installdir()}
            import("package.tools.nmake").install(package, configs)
        end
        os.mv(package:installdir("include/apr-1/*"), package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cincludes("apr.h"))
    end)
