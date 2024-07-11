package("pdfio")
    set_homepage("https://www.msweet.org/pdfio")
    set_description("PDFio is a simple C library for reading and writing PDF files.")
    set_license("Apache-2.0")

    add_urls("https://github.com/michaelrsweet/pdfio/archive/refs/tags/$(version).tar.gz",
             "https://github.com/michaelrsweet/pdfio.git")

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
