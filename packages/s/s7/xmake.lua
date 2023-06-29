package("s7")

    set_homepage("https://ccrma.stanford.edu/software/snd/snd/s7.html")
    set_description("s7 is a Scheme interpreter intended as an extension language for other applications.")

    add_urls("https://github.com/xmake-mirror/s7.git",
             "https://cm-gitlab.stanford.edu/bil/s7.git")

    add_versions("2023.04.13", "505f98d69be3d9c48e096d6787d2f85c27cb3924")

    add_configs("gmp", {description = "enable gmp support", default = false, type = "boolean"})

    on_load(function (package)
        package:addenv("PATH", "bin")
        if package:config("gmp") then
            package:add("deps", "gmp")
        end
    end)

    if is_plat("linux") then
        add_syslinks("pthread", "dl")
    end

    on_install("bsd", "cross", "cygwin", "linux", "macosx", "mingw", "msys", "wasm", "windows", function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function(package)
        if not package:is_cross() then
            local file = os.tmpfile() .. ".scm"
            io.writefile(file, [[
                (display "Hello World!")
            ]])
            os.vrunv("s7", {file})
        end
        assert(package:check_csnippets([[
            static s7_pointer old_add;           /* the original "+" function for non-string cases */
            static s7_pointer old_string_append; /* same, for "string-append" */

            static s7_pointer our_add(s7_scheme *sc, s7_pointer args)
            {
                /* this will replace the built-in "+" operator, extending it to include strings:
                *   (+ "hi" "ho") -> "hiho" and  (+ 3 4) -> 7
                */
                if ((s7_is_pair(args)) &&
                    (s7_is_string(s7_car(args))))
                    return(s7_apply_function(sc, old_string_append, args));
                return(s7_apply_function(sc, old_add, args));
            }
        ]], {includes = "s7.h"}))
    end)
