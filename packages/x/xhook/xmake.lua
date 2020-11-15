package("xhook")
    set_homepage("https://github.com/iqiyi/xHook")
    set_description("PLT (Procedure Linkage Table) hook library for Android native ELF (executable and shared libraries)")
    add_urls("https://github.com/iqiyi/xHook/archive/$(version).tar.gz")

    add_versions("v1.2.0", "b4153559ea4d0f975ad46783374a0103e165a81c767e9515a3b2d6efe70a06ae")
    add_syslinks("log")

    on_install("android", function (package)
        os.cd("libxhook/jni")
        io.writefile("xmake.lua", [[
            target("xhook")
                set_kind("static")
                add_links("log")
                add_cflags("-Wall", "-Wextra", "-Werror", "-fvisibility=hidden")
                add_files("*.c")
                add_headerfiles("xhook.h")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("xhook_register", {includes = "xhook.h"}))
    end)