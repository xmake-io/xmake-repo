package("libxmake")
    set_homepage("https://xmake.io")
    set_description("The c/c++ bindings of the xmake core engine")

    add_urls("https://github.com/xmake-io/xmake/releases/download/$(version)/xmake-$(version).tar.gz")
    add_urls("https://gitee.com/tboox/xmake.git",
             "https://github.com/xmake-io/xmake.git",
             "https://gitlab.com/tboox/xmake.git")

    add_versions("v3.0.6", "1f7bd9ab7f7cbeade4ecd81f3580898e8d78aa5f64cea44239a9506ff41bc397")
    add_versions("v3.0.5", "b947666281222f79e082283b6f84e68880c499305890f6ab8b03b8bac82456dc")
    add_versions("v3.0.4", "b6968dbe266029987bee0a389175f8898042c0bd38f279befc40adaf8e67ce04")
    add_versions("v3.0.3", "49d70671f40f28a1d8125df1a2b318cbd44608a26fa3c60587be3a5ad835b0fb")
    add_versions("v3.0.2", "a89665b6685ea4b0dffc6d9f92eb15e9ee602fdfac0d27cee5632605124593e3")
    add_versions("v3.0.1", "2b5db9586d57f35392ad59a6386c714598a5148d91acac2945f35a5ed32bef79")
    add_versions("v3.0.0", "e749c2a902a1b88e6e3b73b78962a6417c9a04f91ce3c6e174a252598f10eb28")
    add_versions("v2.9.9", "e92505b83bc9776286eae719d58bcea7ff2577afe12cb5ccb279c81e7dbc702d")
    add_versions("v2.9.8", "e797636aadf072c9b0851dba39b121e93c739d12d78398c91f12e8ed355d6a95")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    add_configs("embed", {description = "Embed lua scripts.", default = true, type = "boolean"})

    add_patches("3.0.6", "patches/3.0.6/fix_embed_binary.diff", "862a73b2f89930aaf353ddedeed7060b0407a1e57495918e60073deea497bced")
    add_patches("2.9.8", "patches/2.9.8/xmake-cli.patch", "8d1cc779a4ee6a6958c4e5d9dae2f8811210518a1a48f47c540c363053f6b10b")

    add_includedirs("include")
    if is_plat("windows") then
        add_ldflags("/export:malloc", "/export:free", "/export:memmove")
        add_syslinks("kernel32", "user32", "gdi32", "ws2_32", "advapi32", "shell32")
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
        package:add("links", "xmake", "tbox", "sv", "lua-cjson", "lz4", "lua")
        if package:is_debug() then
            package:add("defines", "__tb_debug__")
        end
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
