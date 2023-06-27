package("mma")

    set_homepage("https://github.com/jdumas/mma")
    set_description("A self-contained C++ implementation of MMA and GCMMA.")
    set_license("MIT")

    add_urls("https://github.com/jdumas/mma.git")
    add_versions("2018.08.01", "aa51333f942220ac98e5957accb1b7e60590ec6f")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("cxx11")
            target("mma")
                set_kind("$(kind)")
                add_files("src/mma/MMASolver.cpp")
                add_headerfiles("src/(mma/MMASolver.h)")
            target("gcmma")
                set_kind("$(kind)")
                add_files("src/gcmma/GCMMASolver.cpp")
                add_headerfiles("src/(gcmma/GCMMASolver.h)")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("MMASolver", {includes = "mma/MMASolver.h"}))
    end)
