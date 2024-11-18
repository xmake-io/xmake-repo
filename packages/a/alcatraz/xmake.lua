package("alcatraz")
    set_kind("binary")
    set_homepage("https://github.com/weak1337/Alcatraz")
    set_description("x64 binary obfuscator")

    set_urls("https://github.com/weak1337/Alcatraz.git", {submodules = false})

    add_versions("2023.07.14", "739e65ebadaeb3f8206fb2199700725331465abb")

    add_deps("asmjit", "zydis")

    on_install("@windows", function (package)
        io.replace("Alcatraz/obfuscator/obfuscator.cpp", "#include <iostream>",
            "#include <iostream>\n#include <bit>", {plain = true})

        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("asmjit", "zydis")
            set_languages("c++20")
            target("alcatraz")
                set_kind("binary")
                add_files("Alcatraz/**.cpp")
                add_packages("asmjit", "zydis")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        os.vrun("alcatraz")
    end)
