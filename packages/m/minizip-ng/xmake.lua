package("minizip-ng")
    set_homepage("https://github.com/zlib-ng/minizip-ng")
    set_description("Fork of the popular zip manipulation library found in the zlib distribution.")
    set_license("zlib")

    add_urls("https://github.com/zlib-ng/minizip-ng/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zlib-ng/minizip-ng.git")

    add_versions("4.1.0", "85417229bb0cd56403e811c316150eea1a3643346d9cec7512ddb7ea291b06f2")
    add_versions("4.0.10", "c362e35ee973fa7be58cc5e38a4a6c23cc8f7e652555daf4f115a9eb2d3a6be7")
    add_versions("4.0.8", "c3e9ceab2bec26cb72eba1cf46d0e2c7cad5d2fe3adf5df77e17d6bbfea4ec8f")
    add_versions("4.0.7", "a87f1f734f97095fe1ef0018217c149d53d0f78438bcb77af38adc21dff2dfbc")
    add_versions("4.0.6", "e96ed3866706a67dbed05bf035e26ef6b60f408e1381bf0fe9af17fe2c0abebc")
    add_versions("4.0.5", "9bb636474b8a4269280d32aca7de4501f5c24cc642c9b4225b4ed7b327f4ee73")
    add_versions("4.0.4", "955800fe39f9d830fcb84e60746952f6a48e41093ec7a233c63ad611b5fcfe9f")
    add_versions("3.0.3", "5f1dd0d38adbe9785cb9c4e6e47738c109d73a0afa86e58c4025ce3e2cc504ed")
    add_versions("3.0.5", "1a248c378fdf4ef6c517024bb65577603d5146cffaebe81900bec9c0a5035d4d")

    add_patches("4.1.0", "patches/4.1.0/fix-bsd.patch", "e70384e66967bb6c75ac7c7b610ea53b0ef3b35289359a4d7118d9310a4a3994")

    add_configs("zlib",  {description = "Enable zlib compression library.", default = true, type = "boolean"})
    add_configs("lzma",  {description = "Enable liblzma compression library.", default = false, type = "boolean"})
    add_configs("bzip2", {description = "Enable bzip2 comppressression library.", default = false, type = "boolean"})
    add_configs("zstd",  {description = "Enable zstd comppressression library.", default = false, type = "boolean"})

    add_deps("cmake")
    if is_plat("linux", "bsd", "android", "cross") then
        add_deps("openssl")
    elseif is_plat("wasm") then
        add_deps("openssl3")
    end

    if is_plat("macosx") then
        add_frameworks("CoreFoundation", "Security")
        add_syslinks("iconv")
    elseif is_plat("iphoneos") then
        add_syslinks("iconv")
    elseif is_plat("windows", "mingw") then
        add_syslinks("crypt32", "advapi32")
    end

    on_load(function (package)
        if package:version() and package:version():ge("4.0") then
            if package:is_plat("macosx", "iphoneos") then
                package:add("deps", "openssl")
            elseif package:is_plat("windows", "mingw") then
                package:add("syslinks", "bcrypt")
            end
        end
        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                if enabled then
                    package:add("deps", name)
                end
            end
        end
    end)

    on_install(function (package)
        -- TODO: add new config for zlib-ng?
        io.replace("CMakeLists.txt", "find_package(ZLIBNG QUIET)", "", {plain = true})
        io.replace("CMakeLists.txt", "find_package(ZLIB-NG QUIET)", "", {plain = true}) -- 4.1.0 version

        local configs = {"-DMZ_LIBCOMP=OFF", "-DMZ_FETCH_LIBS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DMZ_SANITIZER=" .. (package:config("asan") and "Address" or "OFF"))
        if package:config("shared") and package:is_plat("windows") then
            -- https://github.com/zlib-ng/minizip-ng/issues/475
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end

        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                table.insert(configs, "-DMZ_" .. name:upper() .. "=" .. (enabled and "ON" or "OFF"))
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        local includes
        local version = package:version()
        if version then
            if version:ge("4.0") then
                if version:ge("4.0.8") then
                    includes = {"minizip/mz.h", "minizip/zip.h"}
                else
                    includes = {"minizip/mz.h", "minizip/mz_compat.h"}
                end
            else
                includes = {"mz.h", "mz_compat.h"}
            end
        end
        assert(package:has_cfuncs("zipOpen", {includes = includes}))
    end)
