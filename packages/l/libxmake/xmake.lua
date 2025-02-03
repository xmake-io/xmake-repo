package("libxmake")

    set_homepage("https://xmake.io")
    set_description("The c/c++ bindings of the xmake core engine")

    add_urls("https://github.com/xmake-io/xmake/releases/download/$(version)/xmake-$(version).tar.gz")
    add_urls("https://gitee.com/tboox/xmake.git",
             "https://github.com/xmake-io/xmake.git",
             "https://gitlab.com/tboox/xmake.git")

    add_versions("v2.9.7", "248e496a5a734c89e167f931e2620c0ea4109e7ca913dc1022735129a5ffe9d3")
    add_versions("v2.9.6", "47f6efcb00f90c98a02c395f973b4d55bdd3a8fe452676dce57b55c055759686")
    add_versions("v2.9.5", "03feb5787e22fab8dd40419ec3d84abd35abcd9f8a1b24c488c7eb571d6724c8")
    add_versions("v2.9.4", "75e2dde2bd2a48a332989b801ae65077c452d491fec517a9db27a81c8713cdc5")
    add_versions("v2.9.2", "1f617b6a4568c7eb3e8ab0f3a67c16989245adc547e3a7d1fd861acb308fb5b2")
    add_versions("v2.9.1", "a31dbef8c303aea1268068b4b1ac1aec142ac4124c7cb7d9c7eeb57c414f8d15")
    add_versions("v2.8.9", "5f793c393346ef80e47f083ade4d3c2fdfc448658a7917fda35ccd7bd2b911b8")
    add_versions("v2.7.9", "9b42d8634833f4885b05b89429dd60044dca99232f6096320b8d857fb33d2aef")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

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
        package:add("links", "xmake", "tbox", "sv", "lcurses")
        if not package:is_plat("windows") then
            package:add("deps", "ncurses")
        end
        if package:debug() then
            package:add("defines", "__tb_debug__")
        end
        package:add("links", "lua-cjson", "lz4")
        package:add("links", "lua")
        package:add("includedirs", "include/lua")
    end)

    on_install("linux", "macosx", "windows", function (package)
        local configs = {"--onlylib=y"}
        os.cd("core")
        io.replace("xmake.lua", 'set_warnings("all", "error")', "", {plain = true})
        io.replace("xmake.lua", [[option("pdcurses")
    set_default(true)
]], 'option("pdcurses")\nset_default(false)', {plain = true})
        io.replace("src/xmake/engine.c", 'sysarch = "arm64"', 'sysarch = "arm64";', {plain = true})
        io.replace("src/xmake/engine.c", 'sysarch = "arm"', 'sysarch = "arm";', {plain = true})
        io.replace("src/sv/sv/include/semver.h", [[#if defined(_MSC_VER)
typedef __int8 int8_t;]], '#if defined(_MSC_VER) && (_MSC_VER < 1600)\ntypedef __int8 int8_t;', {plain = true})
        import("package.tools.xmake").install(package, configs)
        os.cp("../xmake", package:installdir("share"))
        if package:is_plat("linux", "macosx") and package:has_cfuncs("readline", {links = "readline", includes = {"stdio.h", "readline/readline.h"}}) then
            package:add("syslinks", "readline")
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("xm_engine_init", {includes = "xmake/xmake.h"}))
    end)
