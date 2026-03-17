package("libxlsxwriter")
    set_homepage("https://libxlsxwriter.github.io")
    set_description("A C library for creating Excel XLSX files.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/jmcnamara/libxlsxwriter/archive/refs/tags/$(version).tar.gz")
    add_urls("https://github.com/jmcnamara/libxlsxwriter.git", {alias = "git"})

    add_versions("v1.2.3", "63f070c19c97ce4d5dfcbc1fa8cc5237d4c9decf39341a31188dbdceef93b542")
    add_versions("git:1.1.5", "RELEASE_1.1.5")

    add_configs("tmpfile", {description = "Use the C standard library's tmpfile()", default = false, type = "boolean"})
    add_configs("md5", {description = "Build libxlsxwriter without third party MD5 lib", default = false, type = "boolean"})
    add_configs("openssl_md5", {description = "Build libxlsxwriter with the OpenSSL MD5 lib", default = false, type = "boolean"})
    add_configs("mem_file", {description = "Use fmemopen()/open_memstream() in place of temporary files", default = false, type = "boolean"})
    add_configs("64", {description = "Enable 64-bit filesystem support", default = true, type = "boolean"})
    add_configs("dtoa", {description = "Use the locale independent third party Milo Yip DTOA library", default = false, type = "boolean"})

    add_deps("cmake")
    if is_subhost("windows") then
        add_deps("pkgconf")
    else
        add_deps("pkg-config")
    end
    -- minizip cmake missing iowin32.h
    add_deps("minizip", {configs = {cmake = not is_plat("windows")}})

    if on_check then
        on_check("android", function (package)
            local ndk = package.toolchain("ndk")
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) > 21, "package(libxlsxwriter): need ndk api level > 21 for android")
        end)
    end

    on_load(function (package)
        if package:config("openssl_md5") then
            package:add("deps", "openssl")
        end
    end)

    on_install(function (package)
        io.replace("CMakeLists.txt", "set(CMAKE_POSITION_INDEPENDENT_CODE ON)", "", {plain = true})

        local version = package:version()
        if version then
            -- Remove `find_package(MINIZIP NAMES unofficial-minizip REQUIRED)` for windows
            io.replace("CMakeLists.txt", "    if(MSVC)", "if(0)", {plain = true})
            if version:ge("1.1.9") then
                io.replace("CMakeLists.txt", "list(APPEND LXW_PRIVATE_INCLUDE_DIRS ${MINIZIP_INCLUDE_DIRS}/..)", "list(APPEND LXW_PRIVATE_INCLUDE_DIRS ${MINIZIP_INCLUDE_DIRS})", {plain = true})
            else
                io.replace("CMakeLists.txt", [[find_package(ZLIB REQUIRED "1.0")]], "find_package(ZLIB REQUIRED)", {plain = true})
                io.replace("CMakeLists.txt", [[find_package(MINIZIP REQUIRED "1.0")]], "", {plain = true})
                local file = io.open("CMakeLists.txt", "a")
                file:write([[
                    include(FindPkgConfig)
                    pkg_search_module("minizip" REQUIRED IMPORTED_TARGET "minizip")
                    target_link_libraries(${PROJECT_NAME} PUBLIC PkgConfig::minizip)
                ]])
                file:close()
            end
        end

        local configs = {
            "-DBUILD_TESTS=OFF",
            "-DBUILD_EXAMPLES=OFF",
            "-DUSE_STATIC_MSVC_RUNTIME=OFF",
            "-DUSE_SYSTEM_MINIZIP=ON",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_STANDARD_TMPFILE=" .. (package:config("tmpfile") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_NO_MD5=" .. (package:config("md5") and "OFF" or "ON"))
        table.insert(configs, "-DUSE_OPENSSL_MD5=" .. (package:config("openssl_md5") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_MEM_FILE=" .. (package:config("mem_file") and "ON" or "OFF"))
        table.insert(configs, "-DIOAPI_NO_64=" .. (package:config("64") and "OFF" or "ON"))
        table.insert(configs, "-DUSE_DTOA_LIBRARY=" .. (package:config("dtoa") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("workbook_new", {includes = "xlsxwriter.h"}))
    end)
