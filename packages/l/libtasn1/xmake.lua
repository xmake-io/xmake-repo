package("libtasn1")

    set_homepage("https://www.gnu.org/software/libtasn1/")
    set_description("Libtasn1 is the ASN.1 library used by GnuTLS, p11-kit and some other packages.")
    set_license("LGPL-2.1")

    add_urls("https://ftpmirror.gnu.org/gnu/libtasn1/libtasn1-$(version).tar.gz",
             "https://ftp.gnu.org/gnu/libtasn1/libtasn1-$(version).tar.gz")
    add_versions("4.15.0", "dd77509fe8f5304deafbca654dc7f0ea57f5841f41ba530cff9a5bf71382739e")
    add_versions("4.19.0", "1613f0ac1cf484d6ec0ce3b8c06d56263cc7242f1c23b30d82d23de345a63f7a")

    on_install("macosx", "linux", function (package)
        package:addenv("PATH", "bin")
        local configs = {"--disable-doc", "--disable-dependency-tracking"}
        if package:config("shared") then
            table.insert(configs, "--enable-shared")
            table.insert(configs, "--disable-static")
        else
            table.insert(configs, "--disable-shared")
            table.insert(configs, "--enable-static")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("asn1_create_element", {includes = "libtasn1.h"}))
    end)
