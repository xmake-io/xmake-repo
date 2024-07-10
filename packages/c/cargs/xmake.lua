package("cargs")
    set_homepage("https://likle.github.io/cargs/")
    set_description("A lightweight cross-platform getopt alternative that works on Linux, Windows and macOS. Command line argument parser library for C/C++. Can be used to parse argv and argc parameters.")
    set_license("MIT")

    add_urls("https://github.com/likle/cargs/archive/refs/tags/$(version).tar.gz",
             "https://github.com/likle/cargs.git")
    add_versions("v1.2.0", "0b33379e3d3c8cb3e22f33d3e1a260adcd366970868bc9b7c47237f24188ff25")
    add_versions("v1.1.0", "87e7da5b539f574d48529870cb0620ef5a244a5ee2eac73cc7559dedc04128ca")
    add_versions("v1.0.3", "ddba25bd35e9c6c75bc706c126001b8ce8e084d40ef37050e6aa6963e836eb8b")

    add_deps("cmake")

    on_install(function (package)
        -- Disable warnings as errors
        io.replace("cmake/EnableWarnings.cmake", "[^\n]*WX[^\n]*", "")
        io.replace("cmake/EnableWarnings.cmake", "[^\n]*Werror[^\n]*", "")

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("cag_option_prepare", {includes = "cargs.h"}))
    end)
