package("bhook")
    set_homepage("https://github.com/bytedance/bhook/tree/main/doc#readme")
    set_description("ByteHook is an Android PLT hook library which supports armeabi-v7a, arm64-v8a, x86 and x86_64.")
    set_license("MIT")

    add_urls("https://github.com/bytedance/bhook/archive/refs/tags/$(version).tar.gz",
             "https://github.com/bytedance/bhook.git")

    add_versions("v1.1.1", "10b501045d89d24a46c2527e516d98f4b38208663a83da21270f5068d9c27e31")

    add_deps("linux-syscall-support")

    if is_arch("arm.*") then
        add_deps("shadowhook")
    end

    on_install("android", function (package)
        io.replace("bytehook/src/main/cpp/bh_safe.c", [[#include "linux_syscall_support.h"]], [[#include <lss/linux_syscall_support.h>]], {plain = true})
        os.cd("bytehook/src/main/cpp")
        os.mv("bytehook.map.txt", "bytehook.map")
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug", "mode.asan")

            add_requires("linux-syscall-support")
            add_packages("linux-syscall-support")

            if is_arch("arm.*") then
                add_requires("shadowhook")
                add_packages("shadowhook")
            end

            target("bhook")
                set_kind("$(kind)")
                set_languages("c17")

                add_syslinks("log")

                add_files("*.c")

                if is_arch("arm64.*", "aarch64") then
                    add_ldflags("-Wl,-z,max-page-size=16384")
                end

                add_includedirs(".", "include", "third_party/bsd")
                add_headerfiles("include/(**.h)")

                if is_mode("asan") then
                    add_cflags("-fno-omit-frame-pointer")
                else
                    set_optimize("smallest")
                    add_cflags("-ffunction-sections", "-fdata-sections")
                    add_ldflags("-Wl,--exclude-libs,ALL", "-Wl,--gc-sections")
                    add_files("bytehook.map")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("bytehook_get_version", {includes = "bytehook.h"}))
    end)
