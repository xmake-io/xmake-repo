package("nuklear")

    set_kind("library", {headeronly = true})
    set_homepage("https://immediate-mode-ui.github.io/Nuklear/doc/index.html")
    set_description("A single-header ANSI C immediate mode cross-platform GUI library")
    set_license("MIT")

    add_urls("https://github.com/Immediate-Mode-UI/Nuklear/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Immediate-Mode-UI/Nuklear.git")

    add_versions("4.10.5", "6c80cbd0612447421fa02ad92f4207da2cd019a14d94885dfccac1aadc57926a")

    on_load("mingw", function (package)
        -- see https://github.com/Immediate-Mode-UI/Nuklear/issues/320
        package:add("defines", "NK_INCLUDE_FIXED_TYPES")
    end)

    on_install(function (package)
        os.cp("nuklear.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cincludes("nuklear.h"))
    end)
