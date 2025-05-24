package("wineditline")
    set_homepage("http://mingweditline.sourceforge.net")
    set_description("An EditLine API implementation for the native Windows Console")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/ptosco/wineditline/archive/refs/tags/wineditline-$(version).tar.gz",
             "https://github.com/ptosco/wineditline.git")

    add_versions("2.208", "2df14abed2fadebf6e20bc0853b8b9b01f736ea3a5402420e0192029c6a23d80")
    add_patches("2.208", "patches/2.208/build.diff", "1d1a965c2c07ee930795915a950e3d223b4941229391242d297727e8b5bbbba1")

    add_deps("cmake")

    on_install("mingw", "msys", "windows", function (package)
        io.replace("src/CMakeLists.txt", 'if (MSVC AND uppercase_CMAKE_BUILD_TYPE MATCHES "DEBUG")', "if(0)", {plain = true})

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("history_list", {includes = "editline/readline.h"}))
    end)
