package("libvorbis")

    set_homepage("https://xiph.org/vorbis")
    set_description("Reference implementation of the Ogg Vorbis audio format.")
    set_license("BSD-3")

    set_urls("https://ftp.osuosl.org/pub/xiph/releases/vorbis/libvorbis-$(version).tar.gz",
             "https://github.com/xiph/vorbis/releases/download/v$(version)/libvorbis-$(version).tar.gz",
             "https://gitlab.xiph.org/xiph/vorbis.git")

    add_versions("1.3.7", "0e982409a9c3fc82ee06e08205b1355e5c6aa4c36bca58146ef399621b0ce5ab")

    add_configs("vorbisenc",  {description = "Includes vorbisenc", default = true, type = "boolean"})
    add_configs("vorbisfile", {description = "Includes vorbisfile", default = true, type = "boolean"})

    add_deps("cmake", "libogg")

    on_fetch(function (package, opt)
        if opt.system then
            local vorbis = find_package("vorbis", opt)
            if not vorbis then
                return
            end
            local result = table.copy(vorbis)
            if result.includedirs then
                result.sysincludedirs = result.includedirs
                result.includedirs = nil
            end

            if package:config("vorbisenc") then
                local vorbisenc = find_package("vorbisenc", opt)
                if not vorbisenc then
                    return
                end

                result.sysincludedirs = table.join(vorbisenc.sysincludedirs or vorbisenc.includedirs, result.sysincludedirs or {})
                result.linkdirs = table.join(vorbisenc.linkdirs, result.linkdirs or {})
                result.links = table.join(vorbisenc.links, result.links or {})
            end
            
            if package:config("vorbisfile") then
                local vorbisfile = find_package("vorbisfile", opt)
                if not vorbisfile then
                    return
                end

                result.sysincludedirs = table.join(vorbisfile.sysincludedirs or vorbisfile.includedirs, result.sysincludedirs or {})
                result.linkdirs = table.join(vorbisfile.linkdirs, result.linkdirs or {})
                result.links = table.join(vorbisfile.links, result.links or {})
            end

            return result
        end
    end)

    on_load(function (package)
        local ext = package:is_plat("mingw") and ".dll" or ""
        if package:config("vorbisenc") then
            package:add("links", "vorbisenc" .. ext)
        end
        if package:config("vorbisfile") then
            package:add("links", "vorbisfile" .. ext)
        end
        package:add("links", "vorbis" .. ext)
    end)

    on_install("windows", "linux", "macosx", "iphoneos", "mingw", "android", function (package)
        local configs = {}
        table.insert(configs, "-DBUILD_TESTING=OFF")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if not package:config("vorbisenc") then
            io.replace("CMakeLists.txt", "${CMAKE_CURRENT_BINARY_DIR}/vorbisenc.pc", "", {plain = true})
        end
        if not package:config("vorbisfile") then
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
        if package:config("vorbisenc") then
            assert(package:has_cfuncs("vorbis_encode_init", {includes = "vorbis/vorbisenc.h"}))
        end
        if package:config("vorbisfile") then
            assert(package:has_cfuncs("ov_open_callbacks", {includes = "vorbis/vorbisfile.h"}))
        end
    end)
