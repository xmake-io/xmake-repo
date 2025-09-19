package("libzip")
    set_homepage("https://libzip.org/")
    set_description("A C library for reading, creating, and modifying zip archives.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/nih-at/libzip/releases/download/v$(version)/libzip-$(version).tar.gz",
             "https://libzip.org/download/libzip-$(version).tar.gz", {version = function (version)
                 return tostring(version):sub(2)
         end})
    add_urls("https://github.com/nih-at/libzip.git")

    add_versions("v1.11.4", "82e9f2f2421f9d7c2466bbc3173cd09595a88ea37db0d559a9d0a2dc60dc722e")
    add_versions("v1.11.3", "76653f135dde3036036c500e11861648ffbf9e1fc5b233ff473c60897d9db0ea")
    add_versions("v1.11.2", "6b2a43837005e1c23fdfee532b78f806863e412d2089b9c42b49ab08cbcd7665")
    add_versions("v1.11.1", "c0e6fa52a62ba11efd30262290dc6970947aef32e0cc294ee50e9005ceac092a")
    add_versions("v1.10.1", "9669ae5dfe3ac5b3897536dc8466a874c8cf2c0e3b1fdd08d75b273884299363")
    add_versions("v1.8.0", "30ee55868c0a698d3c600492f2bea4eb62c53849bcf696d21af5eb65f3f3839e")
    add_versions("v1.9.2", "fd6a7f745de3d69cf5603edc9cb33d2890f0198e415255d0987a0cf10d824c6f")

    add_patches("1.11.1", "patches/1.11.1/mingw-shared.patch", "bdd27b2c68ff045160126a6005237105307af06cfc7f89df69e6728ce23fa36a")
    add_patches("<=1.10.1", "patches/1.10.1/mingw.patch", "17513dbef5feca0630ad16a2eacb507fd2ee3d3a47a7c9a660eba24b35ea3fa8")

    add_deps("cmake", "zlib")

    local configdeps = {-- gnutls = "gnutls",
                        mbedtls = "mbedtls",
                        openssl = "openssl",
                        bzip2 = "bzip2",
                        lzma = "lzma",
                        zstd = "zstd"}
    for config, dep in pairs(configdeps) do
        add_configs(config, {description = "Enable " .. config .. " support.", default = false, type = "boolean"})
    end

    if is_plat("windows", "mingw") then
        add_syslinks("advapi32", "bcrypt")
    end

    if on_check then
        on_check("android", function (package)
            if package:is_arch("armeabi-v7a") then
                local ndkver = package:toolchain("ndk"):config("ndkver")
                assert(ndkver and tonumber(ndkver) > 22, "package(libzip) require ndk version > 22")
            end
        end)
    end

    on_load(function (package)
        for config, dep in pairs(configdeps) do
            if package:config(config) then
                package:add("deps", dep)
            end
        end

        if not package:config("sahred") then
            package:add("defines", "ZIP_STATIC")
        end
    end)

    on_install(function (package)
        io.replace("CMakeLists.txt", "Dist(", "#Dist(", {plain = true})

        local configs = {
            "-DBUILD_DOC=OFF",
            "-DBUILD_EXAMPLES=OFF",
            "-DBUILD_REGRESS=OFF",
            "-DBUILD_OSSFUZZ=OFF",
            "-DBUILD_TOOLS=ON",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_GNUTLS=OFF")
        for config, dep in pairs(configdeps) do
            table.insert(configs, "-DENABLE_" .. config:upper() .. "=" .. (package:config(config) and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("zip_source_buffer_create", {includes = "zip.h"}))
    end)
