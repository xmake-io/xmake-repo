package("libheif")

    set_homepage("https://github.com/strukturag/libheif")
    set_description("libheif is an HEIF and AVIF file format decoder and encoder.")
    set_license("LGPL-3.0")

    add_urls("https://github.com/strukturag/libheif/releases/download/v$(version)/libheif-$(version).tar.gz")
    add_versions("1.18.0", "3f25f516d84401d7c22a24ef313ae478781b95f235c250b06152701c401055c3")
    add_versions("1.17.6", "8390baf4913eda0a183e132cec62b875fb2ef507ced5ddddc98dfd2f17780aee")
    add_versions("1.12.0", "e1ac2abb354fdc8ccdca71363ebad7503ad731c84022cf460837f0839e171718")

    add_deps("cmake")
    local configdeps = {"libde265", "x265", "dav1d"}
    for _, conf in ipairs(configdeps) do
        add_configs(conf, {description = "Build " .. conf .. " encoder/decoder.", default = false, type = "boolean"})
    end

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
            "-DWITH_EXAMPLES=OFF",
            -- TODO: package dep
            "-DWITH_AOM=OFF",
            "-DWITH_RAV1E=OFF",
            "-DWITH_LIBSHARPYUV=OFF"
        }
        io.replace("CMakeLists.txt", "find_package(AOM)", "", {plain = true})
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
