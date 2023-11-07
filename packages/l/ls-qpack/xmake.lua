package("ls-qpack")
    set_homepage("https://github.com/litespeedtech/ls-qpack")
    set_description("QPACK compression library for use with HTTP/3")
    set_license("MIT")

    add_urls("https://github.com/litespeedtech/ls-qpack/archive/refs/tags/$(version).tar.gz",
             "https://github.com/litespeedtech/ls-qpack.git")

    add_versions("v2.5.3", "075a05efee27961eac5ac92a12a6e28a61bcd6c122a0276938ef993338577337")

    add_patches("v2.5.3", path.join(os.scriptdir(), "patches", "v2.5.3", "fix-cmake-install.patch"), "7d819b620b5e2bd34ef58a91bf20d882883c7525def9f9f80313b64cba5e5239")

    if not is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    add_deps("xxhash")

    on_install("windows", "linux", "macosx", "bsd", "android", "iphoneos", "cross", function (package)
        local configs = {"-DLSQPACK_TESTS=OFF", "-DLSQPACK_BIN=OFF", "-DLSQPACK_XXH=OFF",}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") and package:config("shared") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = "xxhash"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lsqpack_enc_init", {includes = "lsqpack.h"}))
    end)
