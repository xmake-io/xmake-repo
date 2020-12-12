package("libvorbis")

    set_homepage("https://xiph.org/vorbis")
    set_description("Reference implementation of the Ogg Vorbis audio format.")
    set_license("BSD-3")

    set_urls("https://ftp.osuosl.org/pub/xiph/releases/vorbis/libvorbis-v$(version).tar.gz",
             "https://gitlab.xiph.org/xiph/vorbis.git")

    add_versions("1.3.7", "0e982409a9c3fc82ee06e08205b1355e5c6aa4c36bca58146ef399621b0ce5ab")

    add_deps("cmake", "libogg")

    on_install("windows", "linux", "macosx", "iphoneos", "mingw", "android", function (package)
        local configs = {}
        table.insert(configs, "-DBUILD_TESTING=OFF")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        local libogg = package:dep("libogg")
        if (libogg) then
            local liboggFiles = libogg:fetch()
            if (liboggFiles and liboggFiles.libfiles[1]) then
                table.insert(configs, "-DOGG_INCLUDE_DIR=" .. libogg:installdir("include"))
                table.insert(configs, "-DOGG_LIBRARY=" .. liboggFiles.libfiles[1])
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("vorbis_info_init", {includes = "vorbis/codec.h"}))
    end)
