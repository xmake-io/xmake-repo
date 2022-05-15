package("zlibcomplete")
    set_homepage("https://github.com/rudi-cilibrasi/zlibcomplete")
    set_description("C++ interface to the ZLib library supporting compression with FLUSH, decompression, and std::string. RAII")
    set_license("MIT")

    add_urls("https://github.com/rudi-cilibrasi/zlibcomplete/archive/refs/tags/$(version).tar.gz",
             "https://github.com/rudi-cilibrasi/zlibcomplete.git")
    add_versions("1.0.5", "2b263983823395eaabb091cb9b629eb8466fe24b929bba7ff6d833cadad11977")

    add_deps("cmake", "zlib")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true}) 

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DZLIBCOMPLETE_EXAMPLES=off")
        table.insert(configs, "-DZLIBCOMPLETE_DOCS=off")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.insert(configs, "-DZLIBCOMPLETE_SHARED=on")
        else
            table.insert(configs, "-DZLIBCOMPLETE_STATIC=on")
        end
        import("package.tools.cmake").install(package, configs)
        os.cp("lib/zlc/*.hpp", package:installdir("include", "zlc"))
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("zlc/zlibcomplete.hpp"))
    end)
