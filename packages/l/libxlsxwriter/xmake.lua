package("libxlsxwriter")
    set_homepage("https://libxlsxwriter.github.io")
    set_description("A C library for creating Excel XLSX files.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/jmcnamara/libxlsxwriter/archive/refs/tags/$(version).tar.gz", {alias = "newtag"})
    add_urls("https://github.com/jmcnamara/libxlsxwriter/archive/refs/tags/RELEASE_$(version).tar.gz", {alias = "oldtag"})
    add_urls("https://github.com/jmcnamara/libxlsxwriter.git")

    add_versions("newtag:v1.2.3", "63f070c19c97ce4d5dfcbc1fa8cc5237d4c9decf39341a31188dbdceef93b542")
    add_versions("oldtag:1.1.5", "12843587d591cf679e6ec63ecc629245befec2951736804a837696cdb5d61946")

    add_configs("tmpfile", {description = "Use the C standard library's tmpfile()", default = false, type = "boolean"})
    add_configs("md5", {description = "Build libxlsxwriter without third party MD5 lib", default = false, type = "boolean"})
    add_configs("openssl_md5", {description = "Build libxlsxwriter with the OpenSSL MD5 lib", default = false, type = "boolean"})
    add_configs("mem_file", {description = "Use fmemopen()/open_memstream() in place of temporary files", default = false, type = "boolean"})
    add_configs("64", {description = "Enable 64-bit filesystem support", default = true, type = "boolean"})
    add_configs("dtoa", {description = "Use the locale independent third party Milo Yip DTOA library", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("zlib", "minizip")

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
    end)

    on_install(function (package)
        local configs = {
            "-DBUILD_TESTS=OFF",
            "-DBUILD_EXAMPLES=OFF",

            "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"),
            "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"),
            "-DUSE_STANDARD_TMPFILE=" .. (package:config("tmpfile") and "ON" or "OFF"),
            "-DUSE_NO_MD5=" .. (package:config("md5") and "OFF" or "ON"),
            "-DUSE_OPENSSL_MD5=" .. (package:config("openssl_md5") and "ON" or "OFF"),
            "-DUSE_MEM_FILE=" .. (package:config("mem_file") and "ON" or "OFF"),
            "-DIOAPI_NO_64=" .. (package:config("64") and "OFF" or "ON"),
            "-DUSE_DTOA_LIBRARY=" .. (package:config("dtoa") and "ON" or "OFF"),

            "-DUSE_SYSTEM_MINIZIP=ON",

            "-DUSE_STATIC_MSVC_RUNTIME=" .. ((package:is_plat("windows") and package:config("vs_runtime"):startswith("MT")) and "ON" or "OFF"),
        }

        io.replace("src/packager.c", "minizip/iowin32.h", "iowin32.h", {plain = true})

        if package:is_plat("windows") then
            if package:is_debug() then
                io.replace("CMakeLists.txt", [[${CMAKE_C_FLAGS_DEBUG} /Fd\"${CMAKE_BINARY_DIR}/${PROJECT_NAME}.pdb\")]], "${CMAKE_C_FLAGS_DEBUG}", {plain = true})
            else
                io.replace("CMakeLists.txt", [[${CMAKE_C_FLAGS_RELEASE} /Ox /Zi /Fd\"${CMAKE_BINARY_DIR}/${PROJECT_NAME}.pdb\"]], "${CMAKE_C_FLAGS_RELEASE}", {plain = true})
            end
        end

        local rm_lines
        if package:version():eq("1.1.5") then
            rm_lines={
                -- zlib
                [[find_package(ZLIB REQUIRED "1.0")]],
                -- minizip
                [[find_package(MINIZIP REQUIRED "1.0")]],
            }
        elseif package:version():ge("1.2.3") then
            rm_lines={
                -- zlib
                [[find_package(ZLIB "1.2.8" REQUIRED)]],
                [[target_link_libraries(${PROJECT_NAME} PRIVATE ZLIB::ZLIB)]],
                -- minizip: msvc
                [[find_package(MINIZIP NAMES unofficial-minizip REQUIRED)]],
                [[set(MINIZIP_LIBRARIES unofficial::minizip::minizip)]],
                -- minizip: other
                [[find_package(PkgConfig REQUIRED)]],
                [[pkg_check_modules(MINIZIP minizip)]],
                [[list(APPEND LXW_PRIVATE_INCLUDE_DIRS ${MINIZIP_INCLUDE_DIRS}/..)]],
            }
        end

        for _,l in ipairs(rm_lines) do
            io.replace("CMakeLists.txt", l, "", {plain = true})
        end

        import("package.tools.cmake").install(package, configs, {packagedeps = {"minizip", "zlib"}})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("workbook_new", {includes = "xlsxwriter.h"}))
    end)
