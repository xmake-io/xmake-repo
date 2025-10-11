package("libxlsxwriter")
    set_homepage("https://libxlsxwriter.github.io")
    set_description("A C library for creating Excel XLSX files.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/jmcnamara/libxlsxwriter/archive/refs/tags/$(version).tar.gz", {alias = "newtag"})
    add_urls("https://github.com/jmcnamara/libxlsxwriter/archive/refs/tags/RELEASE_$(version).tar.gz", {alias = "oldtag"})
    add_urls("https://github.com/jmcnamara/libxlsxwriter.git")

    add_versions("newtag:v1.2.3", "63f070c19c97ce4d5dfcbc1fa8cc5237d4c9decf39341a31188dbdceef93b542")
    add_versions("oldtag:1.1.5", "12843587d591cf679e6ec63ecc629245befec2951736804a837696cdb5d61946")

    add_patches("v1.2.3", "patches/v1.2.3/fix-build.diff", "6443592d8274579aab0c2fd2439887649d55a93c9a8f4f4ecbb9cba436d5b101")
    add_patches("v1.2.3", "patches/v1.2.3/minizip.diff", "c9696934e97e24e73525864cd6d25f263a980f7bf1dc172dfe35c3474754af16")
    add_patches("1.1.5", "patches/1.1.5/fix-build.diff", "cd12048e66aa183ac322b355f6a567a602cf66b0ceff3ae813e28939b8c94c71")
    add_patches("1.1.5", "patches/1.1.5/minizip.diff", "133dc2807cf30b99b03075a8b9eda2245e826c88ef0401ac071d21f487a00b0d")

    add_configs("tmpfile", {description = "Use the C standard library's tmpfile()", default = false, type = "boolean"})
    add_configs("md5", {description = "Build libxlsxwriter without third party MD5 lib", default = false, type = "boolean"})
    add_configs("openssl_md5", {description = "Build libxlsxwriter with the OpenSSL MD5 lib", default = false, type = "boolean"})
    add_configs("mem_file", {description = "Use fmemopen()/open_memstream() in place of temporary files", default = false, type = "boolean"})
    add_configs("64", {description = "Enable 64-bit filesystem support", default = true, type = "boolean"})
    add_configs("dtoa", {description = "Use the locale independent third party Milo Yip DTOA library", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("minizip")

    if is_subhost("windows") then
        add_deps("pkgconf")
    else
        add_deps("pkg-config")
    end

    if on_check then
        on_check("android", function (package)
            import("core.tool.toolchain")
            local ndk = toolchain.load("ndk", {plat = package:plat(), arch = package:arch()})
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
            "-DUSE_STATIC_MSVC_RUNTIME=OFF",
        }
        io.replace("src/packager.c", "minizip/iowin32.h", "iowin32.h", {plain = true})
        os.tryrm("cmake/Findminizip.cmake")
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("workbook_new", {includes = "xlsxwriter.h"}))
    end)
