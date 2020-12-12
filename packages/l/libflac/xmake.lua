package("libflac")

    set_homepage("https://xiph.org/flac")
    set_description("Free Lossless Audio Codec")
    set_license("BSD")

    set_urls("https://github.com/xiph/flac/archive/$(version).tar.gz",
             "https://github.com/xiph/flac.git")

    add_versions("1.3.3", "668cdeab898a7dd43cf84739f7e1f3ed6b35ece2ef9968a5c7079fe9adfe1689")

    add_deps("cmake", "libogg")

    if is_plat("linux") then
        add_syslinks("m")
    end

    on_load("windows", function (package)
        if not package:config("shared") then
            package:add("defines", "FLAC__NO_DLL")
        end
    end)

    on_install("windows", "linux", "macosx", "iphoneos", "mingw", "android", function (package)
        local configs = {}
        table.insert(configs, "-DBUILD_CXXLIBS=OFF")
        table.insert(configs, "-DBUILD_DOCS=OFF")
        table.insert(configs, "-DBUILD_PROGRAMS=OFF")
        table.insert(configs, "-DBUILD_EXAMPLES=OFF")
        table.insert(configs, "-DBUILD_TESTING=OFF")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
   end)

    on_test(function (package)
        assert(package:has_cfuncs("FLAC__format_sample_rate_is_valid", {includes = "FLAC/format.h"}))
    end)
