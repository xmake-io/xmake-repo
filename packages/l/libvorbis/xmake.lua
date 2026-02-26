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

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::libvorbis")
    elseif is_plat("linux") then
        add_extsources("pacman::libvorbis", "apt::libvorbis-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::libvorbis")
    end

    add_deps("cmake", "libogg")

    on_fetch(function (package, opt)
        if opt.system then
            local libs = {"vorbis"}
            -- vorbisenc and vorbisfile depends on vorbis, put them first to fix link order
            if package:config("vorbisenc") then
                table.insert(libs, 1, "vorbisenc")
            end
            if package:config("vorbisfile") then
                table.insert(libs, 1, "vorbisfile")
            end

            local result
            for _, name in ipairs(libs) do
                local pkginfo = package:find_package(name, opt)
                if not pkginfo then
                    return -- we must find all wanted libraries
                end

                if not result then
                    result = table.copy(pkginfo)
                else
                    local includedirs = pkginfo.sysincludedirs or pkginfo.includedirs
                    result.links = table.wrap(result.links)
                    result.linkdirs = table.wrap(result.linkdirs)
                    result.includedirs = table.wrap(result.includedirs)
                    table.join2(result.includedirs, includedirs)
                    table.join2(result.linkdirs, pkginfo.linkdirs)
                    table.join2(result.links, pkginfo.links)
                end
                if result then
                    result.version = result.version or pkginfo.version
                end
            end
            return result
        end
    end)

    on_load(function (package)
        local ext = (package:is_plat("mingw") and package:config("shared")) and ".dll" or ""
        if package:config("vorbisenc") then
            package:add("links", "vorbisenc" .. ext)
        end
        if package:config("vorbisfile") then
            package:add("links", "vorbisfile" .. ext)
        end
        package:add("links", "vorbis" .. ext)
    end)

    on_install(function (package)
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

        local configs = {"-DCMAKE_POLICY_DEFAULT_CMP0057=NEW"}
        table.insert(configs, "-DBUILD_TESTING=OFF")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
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
