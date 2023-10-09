package("libxlsxwriter")
    set_homepage("https://libxlsxwriter.github.io")
    set_description("A C library for creating Excel XLSX files.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/jmcnamara/libxlsxwriter/archive/refs/tags/RELEASE_$(version).tar.gz",
             "https://github.com/jmcnamara/libxlsxwriter.git")

    add_versions("1.1.5", "12843587d591cf679e6ec63ecc629245befec2951736804a837696cdb5d61946")

    add_configs("tmpfile", {description = "Use the C standard library's tmpfile()", default = false, type = "boolean"})
    add_configs("md5", {description = "Build libxlsxwriter without third party MD5 lib", default = false, type = "boolean"})
    add_configs("openssl_md5", {description = "Build libxlsxwriter with the OpenSSL MD5 lib", default = false, type = "boolean"})
    add_configs("mem_file", {description = "Use fmemopen()/open_memstream() in place of temporary files", default = false, type = "boolean"})
    add_configs("64", {description = "Enable 64-bit filesystem support", default = true, type = "boolean"})
    add_configs("dtoa", {description = "Use the locale independent third party Milo Yip DTOA library", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("zlib")

    on_load(function (package)
        if package:is_plat("android") then
            import("core.tool.toolchain")
            local ndk = toolchain.load("ndk", {plat = package:plat(), arch = package:arch()})
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) > 21, "package(libxlsxwriter): need ndk api level > 21 for android")
        end
        if package:config("openssl_md5") then
            package:add("deps", "openssl")
        end
        if not package:is_plat("linux", "bsd", "mingw") then
            package:add("deps", "minizip")
        end
    end)

    on_install(function (package)
        local configs = {"-DBUILD_TESTS=OFF", "-DBUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DUSE_STATIC_MSVC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
            if package:is_debug() then
                io.replace("CMakeLists.txt", [[set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /Fd\"${CMAKE_BINARY_DIR}/${PROJECT_NAME}.pdb\"")]], "", {plain = true})
            else
                io.replace("CMakeLists.txt", [[set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /Ox /Zi /Fd\"${CMAKE_BINARY_DIR}/${PROJECT_NAME}.pdb\"")]], "", {plain = true})
            end
        end
        table.insert(configs, "-DUSE_STANDARD_TMPFILE=" .. (package:config("tmpfile") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_NO_MD5=" .. (package:config("md5") and "OFF" or "ON"))
        table.insert(configs, "-DUSE_OPENSSL_MD5=" .. (package:config("openssl_md5") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_MEM_FILE=" .. (package:config("mem_file") and "ON" or "OFF"))
        table.insert(configs, "-DIOAPI_NO_64=" .. (package:config("64") and "OFF" or "ON"))
        table.insert(configs, "-DUSE_DTOA_LIBRARY=" .. (package:config("dtoa") and "ON" or "OFF"))

        io.replace("include/xlsxwriter/packager.h", "minizip/", "", {plain = true})
        io.replace("src/packager.c", "minizip/", "", {plain = true})

        local packagedeps
        if package:is_plat("wasm") then
            table.insert(configs, "-DUSE_SYSTEM_MINIZIP=ON")
            if package:version():le("1.1.5") then
                io.replace("CMakeLists.txt", [[find_package(ZLIB REQUIRED "1.0")]], "", {plain = true})
                io.replace("CMakeLists.txt", [[find_package(MINIZIP REQUIRED "1.0")]], "", {plain = true})
            else
                io.replace("CMakeLists.txt", [[find_package(ZLIB "1.0" REQUIRED)]], "", {plain = true})
                io.replace("CMakeLists.txt", [[find_package(MINIZIP "1.0" REQUIRED)]], "", {plain = true})
            end
            packagedeps = {"minizip", "zlib"}
        elseif package:is_plat("linux", "bsd", "mingw") then
            table.insert(configs, "-DUSE_SYSTEM_MINIZIP=OFF")
            io.replace("CMakeLists.txt", [["1.0"]], "", {plain = true})
        else
            table.insert(configs, "-DUSE_SYSTEM_MINIZIP=ON")
            if package:version():le("1.1.5") then
                io.replace("CMakeLists.txt", [[find_package(ZLIB REQUIRED "1.0")]], "find_package(ZLIB REQUIRED)", {plain = true})
                io.replace("CMakeLists.txt", [[find_package(MINIZIP REQUIRED "1.0")]], "", {plain = true})
            else
                io.replace("CMakeLists.txt", [[find_package(ZLIB "1.0" REQUIRED)]], "find_package(ZLIB REQUIRED)", {plain = true})
                io.replace("CMakeLists.txt", [[find_package(MINIZIP "1.0" REQUIRED)]], "", {plain = true})
            end
            packagedeps = {"minizip"}
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = packagedeps})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("workbook_new", {includes = "xlsxwriter.h"}))
    end)
