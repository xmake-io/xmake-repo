package("sqlite-vec")
    set_homepage("https://github.com/asg017/sqlite-vec")
    set_description("A vector search SQLite extension that runs anywhere!")
    set_license("Apache-2.0")

    add_urls("https://github.com/asg017/sqlite-vec/releases/download/v$(version)/sqlite-vec-$(version)-amalgamation.tar.gz",
             "https://github.com/asg017/sqlite-vec.git")

    add_versions("0.1.6", "99b6ec36e9d259d91bd6cb2c053c3a7660f8791eaa66126c882a6a4557e57d6a")
    add_versions("0.1.3", "cd4da66333caa62dc63dcac99baeed1b38aa327e1d29f12a4a76df34860de442")

    add_deps("sqlite3")

    on_install("!bsd and (!windows or windows|!x86)", function (package)
        if package:is_plat("windows") and not package:config("shared") then
            package:add("defines", "SQLITE_VEC_STATIC")
        end

        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            add_requires("sqlite3")
            target("sqlite-vec")
                set_kind("$(kind)")
                add_files("*.c")
                add_headerfiles("*.h")
                add_packages("sqlite3")
        ]])
        import("package.tools.xmake").install(package)

        if package:is_plat("windows") and package:config("shared") then
            io.replace(package:installdir("include/sqlite-vec.h"), "__declspec(dllexport)", "__declspec(dllimport)", {plain = true})
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("sqlite3_vec_init", {includes = "sqlite-vec.h"}))
    end)
