package("mbedtls")

    set_homepage("https://tls.mbed.org")
    set_description("An SSL library")

    set_urls("https://github.com/ARMmbed/mbedtls/archive/mbedtls-$(version).zip")

    add_versions("2.13.0", "6e747350bc13e8ff51799daa50f74230c6cd8e15977da55dd59f57b23dcf70a6")
    add_versions("2.7.6", "e527d828ab82650102ca8031302e5d4bc68ea887b2d84e43d3da2a80a9e5a2c8")

    if is_host("windows") then
        add_deps("cmake")
    end

    if is_plat("windows") and winos.version():gt("winxp") then
        on_install("windows", function (package)
            import("package.tools.cmake").install(package)
            package:addvar("links", "mbedcrypto", "mbedx509", "mbedtls")
        end)
    end

    on_install("macosx", "linux", function (package)
        io.gsub("./Makefile", "DESTDIR=/usr/local", "DESTDIR=" .. package:installdir())
        os.vrun("make")
        os.vrun("make install")
        package:addvar("links", "mbedcrypto", "mbedx509", "mbedtls")
    end)

