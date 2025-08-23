package("libavif")
    set_homepage("https://github.com/AOMediaCodec/libavif")
    set_description("libavif - Library for encoding and decoding .avif files")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/AOMediaCodec/libavif/archive/refs/tags/$(version).tar.gz",
             "https://github.com/AOMediaCodec/libavif.git")

    add_versions("v1.3.0", "0a545e953cc049bf5bcf4ee467306a2f113a75110edf59e61248873101cd26c1")
    add_versions("v1.2.1", "9c859c7c12ccb0f407511bfe303e6a7247f5f6738f54852662c6df8048daddf4")
    add_versions("v1.1.1", "914662e16245e062ed73f90112fbb4548241300843a7772d8d441bb6859de45b")
    add_versions("v1.1.0", "edb31951005d7a143be1724f24825809599a4832073add50eaf987733defb5c8")
    add_versions("v1.0.4", "dc56708c83a4b934a8af2b78f67f866ba2fb568605c7cf94312acf51ee57d146")
    add_versions("v0.9.1", "8526f3fff34a05a51d7c703cdcf1d0d38c939b5b6dd4bb7d3a3405ddad88186c")

    add_configs("aom", {description = "Use the aom codec for encoding/decoding.", default = false, type = "boolean"})
    add_configs("dav1d", {description = "Use the dav1d codec for decoding.", default = false, type = "boolean"})
    add_configs("libgav1", {description = "Use the libgav1 codec for decoding.", default = false, type = "boolean", readonly = true})
    add_configs("rav1e", {description = "Use the rav1e codec for encoding.", default = false, type = "boolean", readonly = true})
    add_configs("svt_av1", {description = "Use the svt-av1 codec for encoding.", default = false, type = "boolean"})
    add_configs("libsharpyuv", {description = "Use libsharpyuv", default = false, type = "boolean", readonly = true})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("m", "pthread")
    end

    add_deps("cmake")
    add_deps("libyuv")

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk"):config("ndkver")
            assert(ndk and tonumber(ndk) > 22, "package(libavif): library deps libyuv need ndk version > 22")
        end)
        on_check("linux", function (package)
            if package:is_arch("arm64") then
                raise("package(libavif): library deps libyuv unsupport compile flags -march=armv9-a+sme")
            end
        end)
    end

    on_load(function (package)
        local config_to_dep_name = {
            ["svt_av1"] = "svt-av1",
            -- ["libsharpyuv"] = "libwebp",
        }
        for name, enabled in table.orderpairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") and name ~= "tools" then
                if package:config(name) then
                    package:add("deps", config_to_dep_name[name] or name)
                end
            end
        end

        if package:config("tools") then
            package:add("deps", "libpng", "libjpeg-turbo", "libxml2", {private = true})
        end

        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "AVIF_DLL")
        end
    end)

    on_install("!cross and !wasm", function (package)
        io.replace("CMakeLists.txt", "set(CMAKE_POSITION_INDEPENDENT_CODE ON)", "", {plain = true})
        if package:config("aom") then
            io.replace("CMakeLists.txt",
                "check_avif_option(AVIF_CODEC_AOM TARGET aom PKG_NAME aom)",
                "find_package(aom REQUIRED)", {plain = true})
        end
        if package:config("dav1d") then
            io.replace("CMakeLists.txt",
                "check_avif_option(AVIF_CODEC_DAV1D TARGET dav1d::dav1d PKG_NAME dav1d)",
                "find_package(dav1d REQUIRED)", {plain = true})
        end
        if package:config("svt_av1") then
            io.replace("CMakeLists.txt",
                "check_avif_option(AVIF_CODEC_SVT TARGET SvtAv1Enc PKG_NAME svt)",
                "find_package(svt REQUIRED)\nfind_package(cpuinfo REQUIRED)", {plain = true})
            io.replace("CMakeLists.txt",
                "avif_target_link_library(SvtAv1Enc)",
                "avif_target_link_library(SvtAv1Enc)\navif_target_link_library(cpuinfo::cpuinfo)", {plain = true})
        end
        if package:config("tools") then
            io.replace("CMakeLists.txt",
                "check_avif_option(AVIF_LIBXML2 TARGET LibXml2::LibXml2 PKG_NAME LibXml2)",
                "find_package(LibXml2 CONFIG REQUIRED)", {plain = true})
        end

        local configs = {"-DAVIF_ENABLE_WERROR=OFF", "-DAVIF_BUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        local config_map = {
            ["aom"] = "AVIF_CODEC_AOM",
            ["dav1d"] = "AVIF_CODEC_DAV1D",
            ["libgav1"] = "AVIF_CODEC_LIBGAV1",
            ["rav1e"] = "AVIF_CODEC_RAV1E",
            ["svt_av1"] = "AVIF_CODEC_SVT",
            ["libsharpyuv"] = "AVIF_LIBSHARPYUV",
        }
        for name, enabled in table.orderpairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") and name ~= "tools" then
                local key = config_map[name] or name
                local value
                if key:startswith("AVIF_CODEC_") then
                    value = enabled and "ON" or "OFF"
                    table.insert(configs, format("-D%s_ENABLED=%s", key, value))
                else
                    value = enabled and "SYSTEM" or "OFF"
                end
                table.insert(configs, format("-D%s=%s", key, value))
            end
        end
        table.insert(configs, "-DAVIF_BUILD_APPS=" .. (package:config("tools") and "ON" or "OFF"))
        table.insert(configs, "-DAVIF_ZLIBPNG=" .. (package:config("tools") and "SYSTEM" or "OFF"))
        table.insert(configs, "-DAVIF_JPEG=" .. (package:config("tools") and "SYSTEM" or "OFF"))
        table.insert(configs, "-DAVIF_LIBXML2=" .. (package:config("tools") and "SYSTEM" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("avifImageCreate", {includes = "avif/avif.h"}))
    end)
