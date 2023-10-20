package("microprofile")
    set_homepage("https://github.com/jonasmr/microprofile")
    set_description("microprofile is an embeddable profiler")
    set_license("Unlicense")

    add_urls("https://github.com/jonasmr/microprofile/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jonasmr/microprofile.git")

    add_versions("v4.0", "59cd3ee7afd3ce5cfeb7599db62ccc0611818985a8e649353bec157122902a5c")

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32", "advapi32", "shell32")
        add_configs("shared", {description = "Build shared binaries.", default = false, type = "boolean", readonly = true})
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("stb")

    on_install("windows", "linux", "macosx", "bsd", "android", "iphoneos", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("c++11")
            add_requires("stb")
            target("microprofile")
                set_kind("$(kind)")
                add_files("microprofile.cpp")
                add_headerfiles("microprofile.h", "microprofile_html.h")
                if is_plat("windows", "mingw") then
                    add_syslinks("ws2_32", "advapi32", "shell32")
                    if is_plat("windows") and is_kind("shared") then
                        add_rules("utils.symbols.export_all", {export_classes = true})
                    end
                elseif is_plat("linux") then
                    add_syslinks("pthread", "bsd")
                end
                add_packages("stb")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("MicroProfileFlip", {includes = "microprofile.h"}))
    end)
