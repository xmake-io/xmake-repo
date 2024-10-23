package("apr")
    set_homepage("https://github.com/apache/apr")
    set_description("Mirror of Apache Portable Runtime")
    set_license("Apache-2.0")

    add_urls("https://github.com/apache/apr/archive/refs/tags/$(version).tar.gz",
             "https://github.com/apache/apr.git")
    add_versions("1.7.5", "6d0712c529503cd2457011d03164491bbc16d0050bc40ef89568b1ac491c6600")
    add_versions("1.7.4", "060b6e5ca8b3251545a93777c9ef744ceff02d4a59bb60a7dd9b3da9da33673e")
    add_versions("1.7.0", "a7e2c5e6d60f6c7b1611b31a2f914a3e58f44eded5b064f0bae43ff30b16a4e6")

    if is_plat("linux") then
        add_deps("libtool", "python")
        add_patches("1.7.0", path.join(os.scriptdir(), "patches", "1.7.0", "common.patch"), "bbfef69c914ca1ab98a9d94fc4794958334ce5f47d8c08c05e0965a48a44c50d")
    elseif is_plat("windows") then
        add_deps("cmake")
        add_syslinks("wsock32", "ws2_32", "advapi32", "shell32", "rpcrt4")
    end

    on_install("linux", "macosx|x86_64", function (package)
        local configs = {}
        if package:is_plat("linux") then
            os.vrunv("sh", {"./buildconf"})
            io.replace("configure", "RM='$RM'", "RM='$RM -f'")
        else
            io.replace("configure.in", "pid_t_fmt='#error Can not determine the proper size for pid_t'", "pid_t_fmt='#define APR_PID_T_FMT \"d\"'")
            os.vrunv("sh", {"./buildconf"})
            table.insert(configs, "CFLAGS=-DAPR_IOVEC_DEFINED")
        end
        import("package.tools.autoconf").install(package, configs)
        if package:config("shared") then
            os.rm(package:installdir("lib/*.a"))
        else
            os.tryrm(package:installdir("lib/*.so*"))
            os.tryrm(package:installdir("lib/*.dylib"))
        end
        package:add("links", "apr-1")
        package:add("includedirs", "include/apr-1")
    end)

    on_install("windows|x86", "windows|x64", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DAPR_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DAPR_BUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)
        -- libapr-1 is shared, apr-1 is static
        if package:config("shared") then
            package:add("defines", "APR_DECLARE_EXPORT")
            os.rm(package:installdir("lib/apr-1.lib"))
            os.rm(package:installdir("lib/aprapp-1.lib"))
        else
            package:add("defines", "APR_DECLARE_STATIC")
            os.rm(package:installdir("lib/lib*.lib"))
            os.rm(package:installdir("bin/lib*.dll"))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("apr_initialize", {includes = "apr_general.h"}))
    end)
