package("stfl")
    set_homepage("https://github.com/newsboat/stfl")
    set_description("stfl with Newsboat-related bugfixes")
    set_license("LGPL-3.0")

    add_urls("https://github.com/newsboat/stfl.git")

    add_versions("2024.12.24", "bbb2404580e845df2556560112c8aefa27494d66")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("ncurses")

    on_install("!wasm and !iphoneos and @!windows", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            add_requires("ncurses")
            target("stfl")
                set_kind("$(kind)")
                add_files("*.c|example.c")
                add_files("widgets/*.c")
                add_includedirs(".")
                add_defines("_XOPEN_SOURCE=700", "_GNU_SOURCE")
                add_headerfiles("stfl.h")

                if is_plat("linux", "bsd") then
                    add_syslinks("pthread")
                end
                add_packages("ncurses")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("stfl_create", {includes = "stfl.h"}))
    end)
