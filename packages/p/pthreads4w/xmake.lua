package("pthreads4w")

    set_homepage("https://sourceforge.net/projects/pthreads4w/")
    set_description("POSIX Threads for Win32")

    set_urls("https://github.com/xmake-mirror/pthreads4w/archive/$(version).tar.gz",
             "https://github.com/xmake-mirror/pthreads4w.git",
             "https://gitee.com/xmake-mirror/pthreads4w.git")

    add_versions("3.0.0", "31f20963840c26d78fb20224577b7e677018b3eb3000c3570db88528043adc20")

    add_includedirs("include/pthread")

    on_install("windows", function (package)
        local target = "VC"
        if not package:config("shared") then
            target = target .. "-static"
        end
        if package:debug() then
            target = target .. "-debug"
        end
        import("package.tools.nmake").build(package, {"-f", "Makefile", target})
        os.cp("*.lib", package:installdir("lib"))
        os.cp("*.h", package:installdir("include/pthread"))
        if package:config("shared") then
            os.cp("*.dll", package:installdir("bin"))
            package:add("PATH", "bin")
        end
        if package:debug() then
            os.cp("*.pdb", package:installdir("lib"))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pthread_create", {includes = "pthread.h"}))
    end)
