package("libzip")

    set_homepage("https://libzip.org/")
    set_description("A C library for reading, creating, and modifying zip archives.")
    set_license("BSD-3-Clause")

    add_urls("https://libzip.org/download/libzip-$(version).tar.gz")
    add_versions("1.8.0", "30ee55868c0a698d3c600492f2bea4eb62c53849bcf696d21af5eb65f3f3839e")

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

    if is_plat("windows") then
        add_syslinks("Advapi32")
    end

    on_load("windows", "macosx", "linux", function (package)
        for config, dep in pairs(configdeps) do
            if package:config(config) then
                package:add("deps", dep)
            end
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
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
