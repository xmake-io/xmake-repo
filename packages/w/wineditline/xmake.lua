package("wineditline")
    set_homepage("http://mingweditline.sourceforge.net")
    set_description("An EditLine API implementation for the native Windows Console")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/ptosco/wineditline/archive/refs/tags/wineditline-$(version).tar.gz",
             "https://github.com/ptosco/wineditline.git")

    add_versions("2.208", "2df14abed2fadebf6e20bc0853b8b9b01f736ea3a5402420e0192029c6a23d80")
    add_patches("2.208", "patches/2.208/build.diff", "f77caa6a795f797f735079ca8d25b8bd6b328bf76084384c9c95ffbc5dd37bcf")

    add_deps("cmake")

    on_install("mingw", "msys", "windows", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("history_list", {includes = "editline/readline.h"}))
    end)
