package("shadowhook")
    set_homepage("https://github.com/bytedance/android-inline-hook/tree/main/doc")
    set_description("ShadowHook is an Android inline hook library which supports thumb, arm32 and arm64.")
    set_license("MIT")

    add_urls("https://github.com/bytedance/android-inline-hook/archive/refs/tags/$(version).tar.gz",
             "https://github.com/bytedance/android-inline-hook.git")

    add_versions("v1.1.1", "7071be3a1f720489b1ebe1022cbfde2eae7ab2bc88d36e1dcccf363a23d12b32")

    add_deps("xdl", "linux-syscall-support")

    on_install("android", function (package)
        os.cd("shadowhook/src/main/cpp")
        os.mv("shadowhook.map.txt", "shadowhook.map")
        io.writefile("xmake.lua", [[
            add_rules("mode.asan", "mode.release", "mode.debug")
            add_requires("xdl", "linux-syscall-support")
            add_packages("xdl", "linux-syscall-support")
            target("shadowhook")
                set_kind("$(kind)")
                set_languages("c17")

                add_syslinks("log")

                add_files("*.c", "common/*.c")

                if is_arch("arm64.*", "aarch64") then
                    add_files("arch/arm64/*.c")
                    add_includedirs("arch/arm64")
                    add_ldflags("-Wl,-z,max-page-size=16384")
                elseif is_arch("arm.*")
                    add_files("arch/arm/*.c")
                    add_includedirs("arch/arm")
                end

                add_includedirs(".", "include", "common", "third_party/bsd")
                add_headerfiles("include/(**.h)")

                if is_mode("asan") then
                    add_cflags("-fno-omit-frame-pointer")
                else
                    set_optimize("smallest")
                    add_cflags("-ffunction-sections", "-fdata-sections")
                    add_ldflags("-Wl,--exclude-libs,ALL", "-Wl,--gc-sections")
                    add_files("shadowhook.map")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("shadowhook_dlopen", {includes = "shadowhook.h"}))
    end)
