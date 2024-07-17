package("libzip")

    set_homepage("https://libzip.org/")
    set_description("A C library for reading, creating, and modifying zip archives.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/nih-at/libzip/releases/download/v$(version)/libzip-$(version).tar.gz",
             "https://libzip.org/download/libzip-$(version).tar.gz", {version = function (version)
                 return tostring(version):sub(2)
         end})
    add_urls("https://github.com/nih-at/libzip.git")
    add_versions("v1.10.1", "9669ae5dfe3ac5b3897536dc8466a874c8cf2c0e3b1fdd08d75b273884299363")
    add_versions("v1.8.0", "30ee55868c0a698d3c600492f2bea4eb62c53849bcf696d21af5eb65f3f3839e")
    add_versions("v1.9.2", "fd6a7f745de3d69cf5603edc9cb33d2890f0198e415255d0987a0cf10d824c6f")

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
        add_syslinks("advapi32")
    end

    on_load(function (package)
        for config, dep in pairs(configdeps) do
            if package:config(config) then
                package:add("deps", dep)
            end
        end
    end)

    on_install("windows", "macosx", "linux", "mingw", function (package)
        io.replace("CMakeLists.txt", "Dist(", "#Dist(", {plain = true})
        local configs = {"-DBUILD_DOC=OFF", "-DBUILD_EXAMPLES=OFF", "-DBUILD_REGRESS=OFF", "-DBUILD_TOOLS=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
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
