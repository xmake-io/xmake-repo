package("melon")
    set_homepage("http://doc.melonc.io")
    set_description("A generic cross-platform C library that includes many commonly used components and frameworks, and a new scripting language interpreter. It currently supports C99 and Aspect-Oriented Programming (AOP).")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/Water-Melon/Melon.git")
    add_versions("2025.01.18", "9df92922ab384295380d4414493e69983671dbf5")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    on_check("mingw", function (package)
        if is_subhost("macosx") then
            raise("package(melon) is unsupported on Mac OS X subhost.")
        end
        local msystem = os.getenv("MSYSTEM")
        if msystem then
            if msystem ~= "CLANG64" or msystem ~= "CLANGARM64" then 
                raise("package(melon) is unsupported on MinGW64/UCRT64. Use CLANG64/CLANGARM64 Shell.")
            end
        end
    end)

    on_install("!android", function (package)
        if package:is_plat("windows") then
            for _, file in ipairs(os.files("src/*.c")) do
                io.replace(file, "!defined(MSVC)", "0", {plain = true})
                io.replace(file, "defined(MSVC)", "1", {plain = true})
            end
            for _, file in ipairs(os.files("include/*.h")) do
                io.replace(file, "!defined(MSVC)", "0", {plain = true})
                io.replace(file, "defined(MSVC)", "1", {plain = true})
            end
        end

        local home = package:installdir()
        io.replace("src/mln_path.c", "MLN_ROOT", [["]] .. path.join(home, "bin"):gsub([[\]], [[\\]]) .. [["]], {plain = true})
        io.replace("src/mln_path.c", "MLN_NULL", [["]] .. path.join(home, "bin"):gsub([[\]], [[\\]]) .. [["]], {plain = true})
        io.replace("src/mln_path.c", "MLN_LANG_LIB", [["]] .. path.join(home, "lib"):gsub([[\]], [[\\]]) .. [["]], {plain = true})
        io.replace("src/mln_path.c", "MLN_LANG_DYLIB", [["]] .. path.join(home, "lib"):gsub([[\]], [[\\]]) .. [["]], {plain = true})

        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("melon")
                if is_plat("windows") then
                    set_languages("c11")
                else
                    set_languages("gnu99")
                end
                set_kind("$(kind)")
                add_files("src/*.c")
                add_headerfiles("include/*.h")
                add_includedirs("include")
                if is_plat("linux", "bsd") then
                    add_syslinks("dl", "pthread")
                end
                if is_plat("windows", "mingw") then
                    add_syslinks("ws2_32")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mln_aes_init", {includes = "mln_aes.h"}))
    end)
