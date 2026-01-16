package("libheif")
    set_homepage("https://github.com/strukturag/libheif")
    set_description("libheif is an HEIF and AVIF file format decoder and encoder.")
    set_license("LGPL-3.0")

    add_urls("https://github.com/strukturag/libheif/releases/download/v$(version)/libheif-$(version).tar.gz",
            "https://github.com/strukturag/libheif.git")

    add_versions("1.21.2", "75f530b7154bc93e7ecf846edfc0416bf5f490612de8c45983c36385aa742b42")
    add_versions("1.21.1", "9799b4b1c19006f052bcf399c761cc147e279762683cefaf16871dbb9b4ea2a1")
    add_versions("1.21.0", "dc7cef4cf6a1c643eaebffd7b54190681f5b62d913eb6bc9769ad8dacd06b08b")
    add_versions("1.20.2", "68ac9084243004e0ef3633f184eeae85d615fe7e4444373a0a21cebccae9d12a")
    add_versions("1.18.2", "c4002a622bec9f519f29d84bfdc6024e33fd67953a5fb4dc2c2f11f67d5e45bf")
    add_versions("1.18.0", "3f25f516d84401d7c22a24ef313ae478781b95f235c250b06152701c401055c3")
    add_versions("1.17.6", "8390baf4913eda0a183e132cec62b875fb2ef507ced5ddddc98dfd2f17780aee")
    add_versions("1.12.0", "e1ac2abb354fdc8ccdca71363ebad7503ad731c84022cf460837f0839e171718")

    add_deps("cmake")
    add_deps("libjpeg-turbo", {configs = {jpeg = "8"}})
    local configdeps = {"libde265", "x265", "dav1d", "kvazaar", "vvenc", "openh264_encoder", "aom_encoder", "aom_decoder"}
    for _, conf in ipairs(configdeps) do
        add_configs(conf, {description = "Build " .. conf .. " encoder/decoder.", default = false, type = "boolean"})
    end

    on_check("macosx", function (package)
        if macos.version():lt("14") then
            raise("package(libheif): requires macOS version >= 14.")
        end
    end)

    on_load("windows", function (package)
        if not package:config("shared") then
            package:add("defines", "LIBHEIF_STATIC_BUILD")
        end
        for _, conf in ipairs(configdeps) do
            if package:config(conf) then
                package:add("deps", conf)
            end
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs =
        {
            "-DBUILD_TESTING=OFF",
            "-DWITH_EXAMPLES=OFF",
            -- TODO: package dep
            "-DWITH_RAV1E=OFF",
            "-DWITH_LIBSHARPYUV=OFF"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        for _, conf in ipairs(configdeps) do
            table.insert(configs, "-DWITH_" .. conf:upper() .. "=" .. (package:config(conf) and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("heif_get_version_number", {includes = "libheif/heif.h"}))
    end)
