package("libvorbis")

    set_homepage("https://xiph.org/vorbis")
    set_description("Reference implementation of the Ogg Vorbis audio format.")
    set_license("BSD-3")

    set_urls("https://ftp.osuosl.org/pub/xiph/releases/vorbis/libvorbis-$(version).tar.gz",
             "https://github.com/xiph/vorbis/releases/download/v$(version)/libvorbis-$(version).tar.gz",
             "https://gitlab.xiph.org/xiph/vorbis.git")

    add_versions("1.3.7", "0e982409a9c3fc82ee06e08205b1355e5c6aa4c36bca58146ef399621b0ce5ab")

    add_configs("with_vorbisenc",  {description = "Includes vorbisenc", default = true, type = "boolean"})
    add_configs("with_vorbisfile", {description = "Includes vorbisfile", default = true, type = "boolean"})

    add_deps("cmake", "libogg")

    on_fetch(function (package, opt)
        if opt.system then
            local vorbis = find_package("vorbis")
            if not vorbis then
                return
            end
            local result = table.copy(vorbis)

            if package:config("with_vorbisenc") then
                local vorbisenc = find_package("vorbisenc")
                if not vorbisenc then
                    return
                end

                result.includedirs = table.join(vorbisenc.includedirs, result.includedirs or {})
                result.linkdirs = table.join(vorbisenc.linkdirs, result.linkdirs or {})
                result.links = table.join(vorbisenc.links, result.links or {})
            end
            
            if package:config("with_vorbisfile") then
                local vorbisfile = find_package("vorbisfile")
                if not vorbisfile then
                    return
                end

                result.includedirs = table.join(vorbisfile.includedirs, result.includedirs or {})
                result.linkdirs = table.join(vorbisfile.linkdirs, result.linkdirs or {})
                result.links = table.join(vorbisfile.links, result.links or {})
            end

            return result
        end
    end)

    on_load(function (package)
        if package:config("with_vorbisenc") then
            package:add("links", "vorbisenc")
        end
        if package:config("with_vorbisfile") then
            package:add("links", "vorbisfile")
        end
        package:add("links", "vorbis")
    end)

    on_install("windows", "linux", "macosx", "iphoneos", "mingw", "android", function (package)
        local configs = {}
        table.insert(configs, "-DBUILD_TESTING=OFF")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if not package:config("with_vorbisenc") then
            io.replace("CMakeLists.txt", "${CMAKE_CURRENT_BINARY_DIR}/vorbisenc.pc", "", {plain = true})
        end
        if not package:config("with_vorbisfile") then
            io.replace("CMakeLists.txt", "${CMAKE_CURRENT_BINARY_DIR}/vorbisfile.pc", "", {plain = true})
        end
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
        if package:config("with_vorbisenc") then
            assert(package:has_cfuncs("vorbis_encode_init", {includes = "vorbis/vorbisenc.h"}))
        end
        if package:config("with_vorbisfile") then
            assert(package:has_cfuncs("ov_open_callbacks", {includes = "vorbis/vorbisfile.h"}))
        end
    end)
