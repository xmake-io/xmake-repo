package("mbedtls")

    set_homepage("https://tls.mbed.org")
    set_description("An SSL library")

    set_urls("https://github.com/ARMmbed/mbedtls/archive/mbedtls-$(version).zip")

    add_versions("2.25.0", "c2aad438a022c8b0349c9c4ce4a0b40d5df26fe6c63b0c85012b739f279aaf56")
    add_versions("2.13.0", "6e747350bc13e8ff51799daa50f74230c6cd8e15977da55dd59f57b23dcf70a6")
    add_versions("2.7.6", "e527d828ab82650102ca8031302e5d4bc68ea887b2d84e43d3da2a80a9e5a2c8")

    if is_host("windows") then
        add_deps("cmake")
    end

    add_links("mbedtls", "mbedx509", "mbedcrypto")

    if is_plat("windows") and winos.version():gt("winxp") then
        on_install("windows", function (package)
            import("package.tools.cmake").install(package)
        end)
    end
	
    on_install("mingw@windows", function (package)
        import("core.tool.toolchain")
        local bindir = toolchain.load("mingw"):bindir()
        local make = path.join(bindir, "mingw32-make.exe")
        os.vrun(make.." no_test CC=gcc WINDOWS=1")
        os.cp("include/mbedtls", package:installdir("include"))
        os.mkdir(package:installdir().."/lib")
        os.cp("library/libmbedtls.*", package:installdir("lib"))
        os.cp("library/libmbedcrypto.*", package:installdir("lib"))
        os.cp("library/libmbedx509.*", package:installdir("lib"))
    end)
	
    on_install("macosx", "linux", function (package)
        io.gsub("./Makefile", "DESTDIR=/usr/local", "DESTDIR=" .. package:installdir())
        import("package.tools.make").build(package)
        os.vrun("make install")
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mbedtls_ssl_init", {includes = "mbedtls/ssl.h"}))
    end)

