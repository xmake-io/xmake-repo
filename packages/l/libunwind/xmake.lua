package("libunwind")
    set_homepage("https://www.nongnu.org/libunwind/")
    set_description("A portable and efficient C programming interface (API) to determine the call-chain of a program.")
    set_license("MIT")

    add_urls("https://github.com/libunwind/libunwind/releases/download/$(version).tar.gz", {version = function (version)
        if version:eq("v1.5") then
            return "v1.5/libunwind-1.5.0"
        else
            return version .. "/libunwind-" .. (version:gsub("v", ""))
        end
    end})
    add_urls("http://download.savannah.nongnu.org/releases/libunwind/libunwind-$(version).tar.gz", {version = function (version)
        return version:gsub("v", "")
    end})
    add_urls("https://github.com/libunwind/libunwind.git")

    add_versions("v1.8.3", "be30d910e67f58d82e753231f1357f326a1a088acf126b21ff77e60aab19b90b")
    add_versions("v1.8.2", "7f262f1a1224f437ede0f96a6932b582c8f5421ff207c04e3d9504dfa04c8b82")
    add_versions("v1.8.1", "ddf0e32dd5fafe5283198d37e4bf9decf7ba1770b6e7e006c33e6df79e6a6157")
    add_versions("v1.8.0", "b6b3df40a0970c8f2865fb39aa2af7b5d6f12ad6c5774e266ccca4d6b8b72268")
    add_versions("v1.7.2", "a18a6a24307443a8ace7a8acc2ce79fbbe6826cd0edf98d6326d0225d6a5d6e6")
    add_versions("v1.6.2", "4a6aec666991fb45d0889c44aede8ad6eb108071c3554fcdff671f9c94794976")
    add_versions("v1.5", "90337653d92d4a13de590781371c604f9031cdb50520366aa1e3a91e1efb1017")

    add_patches("1.8.0", path.join(os.scriptdir(), "patches", "1.8.0", "fix-arm64.patch"), "5f679af80859b6a50504ec830a4d328c3cf25bef9f2107baed866b438f3818d3")

    add_configs("minidebuginfo", {description = "Enables support for LZMA-compressed symbol tables", default = false, type = "boolean"})
    add_configs("zlibdebuginfo", {description = "Enables support for ZLIB-compressed symbol tables", default = false, type = "boolean"})

    add_deps("autoconf")

    add_defines("_GNU_SOURCE=1")

    on_load("android", "linux", "bsd", "cross", function (package)
        if package:config("minidebuginfo") then
            package:add("deps", "lzma")
        end
        if package:config("zlibdebuginfo") then
            package:add("deps", "zlib")
        end
    end)

    on_install("android|arm64@linux,macosx", "linux", "bsd", "cross", function (package)
        if package:is_plat("bsd") then
            io.replace("src/setjmp/siglongjmp.c", "&wp[JB_MASK]", "(unw_word_t)&wp[JB_MASK]", {plain = true})
        end

        local configs = {"--enable-coredump=no", "--disable-tests"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        table.insert(configs, (package:config("minidebuginfo") and "--enable" or "--disable") .. "-minidebuginfo")
        table.insert(configs, (package:config("zlibdebuginfo") and "--enable" or "--disable") .. "-zlibdebuginfo")
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("_Unwind_Backtrace(0, 0)", {includes = "unwind.h"}))
    end)
