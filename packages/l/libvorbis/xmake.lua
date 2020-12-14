package("libvorbis")

    set_homepage("https://xiph.org/vorbis")
    set_description("Reference implementation of the Ogg Vorbis audio format.")
    set_license("BSD-3")

    set_urls("https://ftp.osuosl.org/pub/xiph/releases/vorbis/libvorbis-$(version).tar.gz",
             "https://github.com/xiph/vorbis/releases/download/v$(version)/libvorbis-$(version).tar.gz",
             "https://gitlab.xiph.org/xiph/vorbis.git")

    add_versions("1.3.7", "0e982409a9c3fc82ee06e08205b1355e5c6aa4c36bca58146ef399621b0ce5ab")

    add_deps("cmake", "libogg")

    on_install("windows", "linux", "macosx", "iphoneos", "mingw", "android", function (package)
        local configs = {}
        table.insert(configs, "-DBUILD_TESTING=OFF")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        -- we pass libogg as packagedeps instead of findOgg.cmake (it does not work)
        local libogg = package:dep("libogg"):fetch()
        if libogg then
            local links = table.concat(table.wrap(libogg.links), " ")
            io.replace("CMakeLists.txt", "find_package(Ogg REQUIRED)", "", {plain = true})
            io.replace("lib/CMakeLists.txt", "Ogg::ogg", links, {plain = true})
        end
        -- disable .def file for mingw
        if package:config("shared") and package:is_plat("mingw") then
            io.replace("lib/CMakeLists.txt", [[list(APPEND VORBIS_SOURCES ../win32/vorbis.def)
    list(APPEND VORBISENC_SOURCES ../win32/vorbisenc.def)
    list(APPEND VORBISFILE_SOURCES ../win32/vorbisfile.def)]], "", {plain = true})
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = "libogg"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("vorbis_info_init", {includes = "vorbis/codec.h"}))
    end)
