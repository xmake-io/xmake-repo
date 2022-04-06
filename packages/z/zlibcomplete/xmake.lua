package("zlibcomplete")
    set_homepage("https://github.com/rudi-cilibrasi/zlibcomplete")
    set_description("C++ interface to the ZLib library supporting compression with FLUSH, decompression, and std::string. RAII")
    set_license("MIT")

    add_urls("https://github.com/rudi-cilibrasi/zlibcomplete/archive/refs/tags/$(version).tar.gz",
             "https://github.com/rudi-cilibrasi/zlibcomplete.git")
    add_versions("1.0.5", "2b263983823395eaabb091cb9b629eb8466fe24b929bba7ff6d833cadad11977")

    add_deps("cmake", "zlib")

    on_install(function (package)
        local zlc_headers_dir = path.join(package:installdir("include"), "zlc")
        os.mkdir(zlc_headers_dir)
        os.cp("lib/zlc/*.hpp", zlc_headers_dir)
        local configs = {}
        table.insert(configs, "-DZLIBCOMPLETE_EXAMPLES=off")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:config("shared") then
          table.insert(configs, "-DZLIBCOMPLETE_SHARED=on")
        else  
          table.insert(configs, "-DZLIBCOMPLETE_STATIC=on")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("zlc/zlibcomplete.hpp"))
    end)
