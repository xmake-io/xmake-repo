package("libargon2")

    set_homepage("https://github.com/P-H-C/phc-winner-argon2")
    set_description("The password hash Argon2, winner of PHC")

    add_urls("https://github.com/P-H-C/phc-winner-argon2/archive/refs/tags/$(version).zip",
             "https://github.com/P-H-C/phc-winner-argon2.git")
    add_versions("20190702", "506a80b90ac3ca8407636f3b26b7fed87a55f2f1275cde850cd6698903c4f008")

    if is_plat("linux") then
        add_syslinks("pthread")
    end
    on_install("windows", "macosx", "linux", "mingw", function (package)
        if not package:config("shared") then
            io.replace("include/argon2.h", "__declspec(dllexport)", "", {plain = true})
        end
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("argon2")
                set_kind("$(kind)")
                add_files("src/core.c", "src/argon2.c", "src/thread.c", "src/encoding.c", "src/blake2/blake2b.c", "src/opt.c")
                add_includedirs("include", "src")
                add_headerfiles("include/argon2.h")
                if not is_plat("windows") then
                    add_defines("A2_VISCTL")
                    add_cflags("-march=native")
                end
                if is_plat("linux") then
                    add_syslinks("pthread")
                end
        ]])
        import("package.tools.xmake").install(package)
        if package:config("shared") then
            io.replace(path.join(package:installdir("include"), "argon2.h"), "__declspec(dllexport)", "__declspec(dllimport)", {plain = true})
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("argon2_error_message", {includes = "argon2.h"}))
    end)
