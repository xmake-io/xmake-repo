package("xunwind")
    set_homepage("https://github.com/hexhacking/xUnwind")
    set_description(":fire: xUnwind is a collection of Android native stack unwinding solutions.")
    set_license("MIT")

    add_urls("https://github.com/hexhacking/xUnwind/archive/refs/tags/$(version).tar.gz",
             "https://github.com/hexhacking/xUnwind.git")

    add_versions("v2.0.0", "c5d82cb62b864bedaa5fe47290f6b4bfd9be7255e4cd4fd0e68c600b49694b1d")

    add_deps("xdl")

    on_install("android", function (package)
        os.cd("xunwind/src/main/cpp")
        os.mv("xunwind.map.txt", "xunwind.map")
        io.writefile("xmake.lua", [[
            add_rules("mode.asan", "mode.release", "mode.debug")
            add_requires("xdl")
            target("xUnwind")
                set_kind("$(kind)")
                set_languages("c17")
                add_files("*.c")
                add_includedirs("include", ".")
                add_headerfiles("include/(**.h)")
                add_packages("xdl")
                add_syslinks("log")
                if is_mode("asan") then
                    add_cflags("-fno-omit-frame-pointer")
                else
                    set_optimize("smallest")
                    add_cflags("-faddrsig", "-ffunction-sections", "-fdata-sections")
                    add_ldflags("-Wl,--icf=all", "-Wl,--exclude-libs,ALL", "-Wl,--gc-sections")
                    add_files("xunwind.map")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("xunwind_cfi_log", {includes = "xunwind.h"}))
    end)
