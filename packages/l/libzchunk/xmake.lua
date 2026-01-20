package("libzchunk")
    set_homepage("https://github.com/zchunk/zchunk")
    set_description("A file format designed for highly efficient deltas while maintaining good compression.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/zchunk/zchunk/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zchunk/zchunk.git")

    add_versions("1.5.3", "832381dafe192109742c141ab90a6bc0a9d7e9926a4bafbdf98f596680da2a95")
    add_versions("1.5.2", "b7346d950fec2e0c72761f2a9148b0ece84574c49076585abf4bebd369cd4c60")
    add_versions("1.5.1", "2c187055e2206e62cef4559845e7c2ec6ec5a07ce1e0a6044e4342e0c5d7771d")

    add_patches("<=1.5.1", "patches/fix-cdecl.patch", "7ca1cbabe8516152e5d4e5cd5dc7c14b2fd0134f8ad7a8fa64159e07998ebeb4")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_configs("zstd", {description = "Enable compression support.", default = false, type = "boolean"})
    add_configs("openssl", {description = "Use openssl or bundled sha libraries.", default = false, type = "boolean"})

    add_deps("meson", "ninja")
    if not is_subhost("windows") then
        add_deps("pkg-config")
    else
        add_deps("pkgconf")
    end
    on_load(function(package)
        if not package:config("shared") then
            package:add("defines", "ZCHUNK_STATIC_LIB")
        end
        if package:config("zstd") then
            package:add("deps", "zstd")
        end
        if package:config("openssl") then
            package:add("deps", "openssl3")
        end
    end)

    -- @see https://github.com/zchunk/zchunk/issues/94
    on_install("!mingw and !msys and !cygwin", function (package)
        local configs = {
            '-Ddocs=false',
            '-Dtests=false',
            '-Dwith-curl=disabled'
        }
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-Dwith-zstd=" .. (package:config("zstd") and "enabled" or "disabled"))
        table.insert(configs, "-Dwith-openssl=" .. (package:config("openssl") and "enabled" or "disabled"))

        io.replace("meson.build", "subdir('src')", "subdir('src/lib')", {plain = true})
        io.replace("meson.build", "not argplib.found()", "false", {plain = true})

        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("zck_create", {configs = {languages = "c99"}, includes = "zck.h"}))
    end)
