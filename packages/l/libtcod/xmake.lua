package("libtcod")
    set_homepage("https://github.com/libtcod/libtcod")
    set_description("A collection of tools and algorithms for developing traditional roguelikes.  Such as field-of-view, pathfinding, and a tile-based terminal emulator.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/libtcod/libtcod/archive/refs/tags/$(version).tar.gz",
             "https://github.com/libtcod/libtcod.git", {submodules = false})

    add_versions("2.2.1", "5eb8e30d937840986c11c7baa22ffa93252aa4ac1824fe2c5fa1d760b3496a8e")
    add_versions("2.1.1", "ee9cc60140f480f72cb2321d5aa50beeaa829b0a4a651e8a37e2ba938ea23caa")
    add_patches("2.1.1", "patches/2.1.1/debundle.diff", "1e0697f13d179164eac0293db4917425b90ddc0f5275388f59f020ebeeb0aed0")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    if is_subhost("windows") then
        add_deps("pkgconf")
    else
        add_deps("pkg-config")
    end
    add_deps("libsdl3", "zlib", "lodepng", "utf8proc", "stb")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        if not package:config("shared") then
            package:add("defines", "LIBTCOD_STATIC")
        end
    end)

    on_install(function (package)
        os.rm("src/vendor/**|stb.c")
        local configs = {
            "-DCMAKE_TOOLCHAIN_FILE=OFF",
            "-DLIBTCOD_SDL3=find_package",
            "-DLIBTCOD_ZLIB=find_package",
            "-DLIBTCOD_LODEPNG=find_package",
            "-DLIBTCOD_UTF8PROC=find_package",
            "-DLIBTCOD_STB=find_package"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <libtcod.hpp>
            void test() {
                tcod::Context g_context;
                auto sdl_window = g_context.get_sdl_window();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
