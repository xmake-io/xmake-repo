package("nmd")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Nomade040/nmd")
    set_description("set of single-header libraries for C/C++. The code is far from finished but some parts are quite usable.")
    set_license("Unlicense")

    add_urls("https://github.com/Nomade040/nmd.git")
    add_versions("2021.03.28", "33ac3b62c7d1eb28ae6b71d4dd78aa133ef96488")

    on_install(function (package)
        os.vcp("nmd_assembly.h", package:installdir("include"))
        os.vcp("nmd_graphics.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("nmd_x86_assemble", {includes = "nmd_assembly.h"}))
    end)
