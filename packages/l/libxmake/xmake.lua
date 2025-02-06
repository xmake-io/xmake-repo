package("libxmake")
    set_homepage("https://xmake.io")
    set_description("The c/c++ bindings of the xmake core engine")

    add_urls("https://github.com/xmake-io/xmake/releases/download/$(version)/xmake-$(version).tar.gz")
    add_urls("https://gitee.com/tboox/xmake.git",
             "https://github.com/xmake-io/xmake.git",
             "https://gitlab.com/tboox/xmake.git")

    add_versions("v2.9.8", "e797636aadf072c9b0851dba39b121e93c739d12d78398c91f12e8ed355d6a95")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    add_configs("embed", {description = "Embed lua scripts.", default = true, type = "boolean"})

    add_patches("2.9.8", "patches/2.9.8/xmake-cli.patch", "8d1cc779a4ee6a6958c4e5d9dae2f8811210518a1a48f47c540c363053f6b10b")

    add_includedirs("include")
    if is_plat("windows") then
        add_ldflags("/export:malloc", "/export:free", "/export:memmove")
        add_syslinks("kernel32", "user32", "gdi32")
        add_syslinks("ws2_32", "advapi32", "shell32")
        add_ldflags("/LTCG")
        add_shflags("/LTCG")
    elseif is_plat("android") then
        add_syslinks("m", "c")
    elseif is_plat("macosx") then
        add_frameworks("CoreFoundation", "CoreServices")
    else
        add_syslinks("pthread", "dl", "m", "c")
    end
    add_defines("LUA_COMPAT_5_1", "LUA_COMPAT_5_2", "LUA_COMPAT_5_3")

    on_load(function (package)
        package:add("links", "xmake", "tbox", "sv")
        if package:debug() then
            package:add("defines", "__tb_debug__")
        end
        package:add("links", "lua-cjson", "lz4")
        package:add("links", "lua")
        package:add("includedirs", "include/lua")
    end)

    on_install("linux", "macosx", "windows", function (package)
        local configs = {
            onlylib = true,
            curses = false,
            embed = package:config("embed")}
        if package:is_plat("windows") then
            configs.pdcurses = false
        end
        os.cd("core")
        io.replace("xmake.lua", 'option("readline")', 'option("readline")\nset_default(false)', {plain = true})
        io.replace("xmake.lua", 'set_warnings("all", "error")', "", {plain = true})
        io.replace("src/xmake/engine.c", 'sysarch = "arm64"', 'sysarch = "arm64";', {plain = true})
        io.replace("src/xmake/engine.c", 'sysarch = "arm"', 'sysarch = "arm";', {plain = true})
        io.replace("src/sv/sv/include/semver.h", [[#if defined(_MSC_VER)
typedef __int8 int8_t;]], '#if defined(_MSC_VER) && (_MSC_VER < 1600)\ntypedef __int8 int8_t;', {plain = true})
        import("package.tools.xmake").install(package, configs)
        if not package:config("embed") then
            os.cp("../xmake", package:installdir("share"))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("xm_engine_init", {includes = "xmake/xmake.h"}))
    end)
