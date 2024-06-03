package("zip")
    set_kind("binary")
    set_homepage("http://www.info-zip.org/Zip.html")
    set_description("Info-ZIP zip utility")

    add_urls("https://github.com/LuaDist/zip.git")
    add_versions("3.0", "f6cfe48f6bc5bf2d505a0e0eb265ce4cb238db89")

    add_deps("cmake")

    on_install("@windows", "@macosx", "@linux", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        os.vrun("zip --help")
    end)

