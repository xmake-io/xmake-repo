package("pdfio")
    set_homepage("https://www.msweet.org/pdfio")
    set_description("PDFio is a simple C library for reading and writing PDF files.")
    set_license("Apache-2.0")

    add_urls("https://github.com/michaelrsweet/pdfio/archive/refs/tags/$(version).tar.gz",
             "https://github.com/michaelrsweet/pdfio.git")

    add_versions("v1.6.1", "de733aad5d5b2d8199667ca28efe01fce17e00743ba021f88303c8a81a5eaa67")
    add_versions("v1.5.0", "895cfa22a895d0afc69a18402f19057ddaf8f035cc0a69f3f2a4cbe55ead9662")
    add_versions("v1.4.0", "c3657cca203801dc111fd41919979068a876473e1ba2c849c7d130c0d4a7ed89")
    add_versions("v1.3.2", "a814fd10e602ffcc9e243674c82268a097992b1c4ad1359d9ab236c56b648b71")
    add_versions("v1.3.1", "0f2933f2d5d0a8c0152510fe5b565715cee8146f3d0d10024e3c597268928574")
    add_versions("v1.3.0", "aae5b4850560869021f6af1700a0681f0d19299554f24abf890a1a78188ddf02")

    if is_plat("windows", "mingw") then
        add_syslinks("advapi32")
    elseif is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    add_deps("zlib")

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk")
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) > 21, "package(pdfio): need ndk api level > 21")
        end)
    end

    on_install(function (package)
        if package:is_plat("mingw") and package:is_arch("i386") then
            io.replace("ttf.c", "typedef __int64 ssize_t;", "", {plain = true})
            io.replace("pdfio.h", "typedef __int64 ssize_t;", "", {plain = true})
        end

        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pdfioArrayCreate", {includes = "pdfio.h"}))
    end)
