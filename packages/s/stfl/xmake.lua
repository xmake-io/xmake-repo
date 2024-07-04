package("stfl")
    set_homepage("https://github.com/newsboat/stfl")
    set_description("stfl with Newsboat-related bugfixes")
    set_license("LGPL-3.0")

    add_urls("https://github.com/newsboat/stfl/archive/c2c10b8a50fef613c0aacdc5d06a0fa610bf79e9.tar.gz"
             "https://github.com/newsboat/stfl.git")

    add_versions("0.24", "59d3f43522161bc2252bd806f973ad64c86a081f06a57a6d628b1c7bdfee7551")

    add_deps("ncurses")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            add_requires("ncurses")
            add_packages("ncurses")
            target("stfl")
                set_kind("$(kind)")
                add_files("*.c|example.c")
                add_files("widgets/*.c")
                add_headerfiles("stfl.h")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("stfl_create", {includes = "stfl.h"}))
    end)
