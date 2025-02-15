package("zint")
    set_homepage("http://www.zint.org.uk")
    set_description("A barcode encoding library supporting over 50 symbologies including Code 128, Data Matrix, USPS OneCode, EAN-128, UPC/EAN, ITF, QR Code, Code 16k, PDF417, MicroPDF417, LOGMARS, Maxicode, GS1 DataBar, Aztec, Composite Symbols and more.")
    set_license("GPL-3.0")

    set_urls("https://github.com/zint/zint/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zint/zint.git")

    add_versions("2.14.0", "affc3e334e8ee0fc5552aabbc5f1360d4d6d9c6f86285c1e138e3efbbdc4abcb")

    add_configs("png", {description = "Build with PNG support", default = false, type = "boolean"})
    add_configs("qt", {description = "Build with Qt support", default = false, type = "boolean", readonly = true})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    add_deps("cmake")

    on_load(function (package)
        if package:config("png") then
            package:add("deps", "libpng")
        end

        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "ZINT_DLL")
        end
    end)

    on_install(function (package)
        local configs = {"-DZINT_UNINSTALL=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DZINT_DEBUG=" .. (package:is_debug() and "ON" or "OFF"))
        table.insert(configs, "-DZINT_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DZINT_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DZINT_SANITIZE=" .. (package:config("asan") and "ON" or "OFF"))

        table.insert(configs, "-DZINT_USE_PNG=" .. (package:config("png") and "ON" or "OFF"))
        table.insert(configs, "-DZINT_USE_QT=" .. (package:config("qt") and "ON" or "OFF"))
        table.insert(configs, "-DZINT_FRONTEND=" .. (package:config("tools") and "ON" or "OFF"))

        local opt = {}
        if package:has_tool("cxx", "cl") then
            opt.cxflags = "/utf-8"
        end
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ZBarcode_Create", {includes = "zint.h"}))
    end)
