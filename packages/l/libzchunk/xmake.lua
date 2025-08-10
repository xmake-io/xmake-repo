package("libzchunk")
    set_homepage("https://github.com/zchunk/zchunk")
    set_description("A file format designed for highly efficient deltas while maintaining good compression.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/zchunk/zchunk/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zchunk/zchunk.git")

    add_versions("1.5.1", "2c187055e2206e62cef4559845e7c2ec6ec5a07ce1e0a6044e4342e0c5d7771d")

    add_patches("<=1.5.1", "patches/fix-cdecl.patch", "7ca1cbabe8516152e5d4e5cd5dc7c14b2fd0134f8ad7a8fa64159e07998ebeb4")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_configs("with_zstd", {description = "Enable compression support.", default = false, type = "boolean"})
    add_configs("with_openssl", {description = "Use openssl or bundled sha libraries.", default = false, type = "boolean"})

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
        if package:config("with_zstd") then
            package:add("deps", "zstd")
        end
        if package:config("with_openssl") then
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
        table.insert(configs, "-Dwith-zstd=" .. (package:config("with_zstd") and "enabled" or "disabled"))
        table.insert(configs, "-Dwith-openssl=" .. (package:config("with_openssl") and "enabled" or "disabled"))

        io.replace("meson.build", "subdir('src')", "subdir('src/lib')", {plain = true})
        io.replace("meson.build", "not argplib.found()", "false", {plain = true})
        if is_plat("windows") then
            -- fix dll name & fix install dir
            io.replace("src/lib/meson.build", "soversion: so_version,", "install_dir: get_option('libdir'),", {plain = true})
            io.replace("src/lib/meson.build", "version: meson.project_version(),", "", {plain = true})
            -- fix lib name
            io.replace("src/lib/meson.build", "lib_suffix = 'lib'", "", {plain = true})
        end

        import("package.tools.meson").install(package, configs)
        if is_plat("windows") and not package:config("shared") then
            -- fix lib name
            os.cd(package:installdir("lib"))
            os.trymv("libzck.a", "zck.lib")
        end
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                zck_create();
            }
        ]]}, {configs = {languages = "c99"}, includes = "zck.h"}))
    end)
