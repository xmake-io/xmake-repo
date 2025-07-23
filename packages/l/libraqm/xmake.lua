package("libraqm")
    set_homepage("https://host-oman.github.io/libraqm")
    set_description("A library for complex text layout")
    set_license("MIT")

    add_urls("https://github.com/HOST-Oman/libraqm/archive/refs/tags/$(version).tar.gz",
             "https://github.com/HOST-Oman/libraqm.git")

    add_versions("v0.10.2", "db68fd9f034fc40ece103e511ffdf941d69f5e935c48ded8a31590468e42ba72")
    add_versions("v0.10.1", "ff8f0604dc38671b57fc9ca5c15f3613e063d2f988ff14aa4de60981cb714134")

    add_configs("sheenbidi", {description = "Enable SheenBidi", default = false, type = "boolean"})

    add_deps("harfbuzz", {configs = {icu = false, freetype = true}})

    on_load(function (package)
        package:add("deps", (package:config("sheenbidi") and "sheenbidi" or "fribidi"))
    end)

    on_install("windows|x64", "windows|x86", "linux", "macosx", function (package)
        local ver = package:version()
        io.writefile("xmake.lua", format([[
            add_requires("harfbuzz", {configs = {icu = false, freetype = true}})
            add_packages("harfbuzz")
            if has_config("sheenbidi") then
                add_requires("sheenbidi")
                add_packages("sheenbidi")
                set_configvar("RAQM_SHEENBIDI", 1)
            else
                add_requires("fribidi")
                add_packages("fribidi")
            end
            add_rules("mode.debug", "mode.release")
            target("raqm")
                set_kind("$(kind)")
                add_files("src/raqm.c")
                add_headerfiles("src/raqm-version.h", "src/raqm.h")
                set_configdir("src")
                add_configfiles("src/raqm-version.h.in", {pattern = "@(.-)@"})
                set_configvar("RAQM_VERSION_MAJOR", %d)
                set_configvar("RAQM_VERSION_MINOR", %d)
                set_configvar("RAQM_VERSION_MICRO", %d)
                set_configvar("RAQM_VERSION", "%s")
                if is_plat("windows") and is_kind("shared") then
                    add_defines("RAQM_API=__declspec (dllexport)")
                end
        ]], ver:major(), ver:minor(), ver:patch(), ver))
        if package:config("sheenbidi") then
            io.replace("src/raqm.c", "#include <SheenBidi.h>", "#include <SheenBidi/SheenBidi.h>", {plain = true})
        else
            io.replace("src/raqm.c", "#include <fribidi.h>", "#include <fribidi/fribidi.h>", {plain = true})
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("raqm_create", {includes = "raqm.h"}))
    end)
