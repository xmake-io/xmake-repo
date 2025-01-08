package("ls-qpack")
    set_homepage("https://github.com/litespeedtech/ls-qpack")
    set_description("QPACK compression library for use with HTTP/3")
    set_license("MIT")

    add_urls("https://github.com/litespeedtech/ls-qpack/archive/refs/tags/$(version).tar.gz",
             "https://github.com/litespeedtech/ls-qpack.git")

    add_versions("v2.6.0", "567a7a86f801eef5df28ce0cc89826d9008a57135027bdf63ba4a1d0639d0c58")
    add_versions("v2.5.5", "8770435b81d13616cf952bd361ec0e6e0fd79acff76dd9f6e75c18fd88b4c4f4")
    add_versions("v2.5.4", "56b96190a1943d75ef8d384b13cd4592a72e3e2d84284f78d7f8adabbc717f3e")
    add_versions("v2.5.3", "075a05efee27961eac5ac92a12a6e28a61bcd6c122a0276938ef993338577337")

    add_patches(">=2.5.5 <=2.6.0", "patches/2.5.5/cmake.patch", "23fd785c3db2e1b43ead464b0ee8d12e9f290fbfdf818c3238cba316df295f08")
    add_patches("2.5.3", "patches/2.5.3/fix-cmake-install.patch", "7d819b620b5e2bd34ef58a91bf20d882883c7525def9f9f80313b64cba5e5239")

    add_deps("cmake")
    add_deps("xxhash")

    on_load(function (package)
        if package:version() and package:version():ge("2.5.5") then
            if is_subhost("windows") then
                package:add("deps", "pkgconf")
            else
                package:add("deps", "pkg-config")
            end
        end
    end)

    on_install(function (package)
        local opt = {}
        if package:version() and package:version():lt("2.5.5") then
            opt.packagedeps = "xxhash"
        end

        local configs = {
            "-DLSQPACK_TESTS=OFF",
            "-DLSQPACK_BIN=OFF",
            "-DLSQPACK_XXH=OFF",
            "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") and package:config("shared") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lsqpack_enc_init", {includes = "lsqpack.h"}))
    end)
