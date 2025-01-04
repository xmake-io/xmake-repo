package("nuklear")

    set_kind("library", {headeronly = true})
    set_homepage("https://immediate-mode-ui.github.io/Nuklear/doc/index.html")
    set_description("A single-header ANSI C immediate mode cross-platform GUI library")
    set_license("MIT")

    add_urls("https://github.com/Immediate-Mode-UI/Nuklear/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Immediate-Mode-UI/Nuklear.git")

    add_versions("4.12.3", "93d32d02ac5c5b17ecc243bb6436da3dc79e656eaa9046e053b8a922e1ee1ad3")
    add_versions("4.12.2", "a705e626a7190722fc5bd3b298e0be35b3d3d92eccf017660ef251cab29fcc94")
    add_versions("4.12.0", "4cb80084d20d20561548a2941b6d1eb7c30e6f0b9405e0d5df84bae3c1d7bbaf")
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
