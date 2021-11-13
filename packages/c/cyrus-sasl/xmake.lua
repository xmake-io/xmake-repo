package("cyrus-sasl")

    set_homepage("https://www.cyrusimap.org/sasl/")
    set_description("Cyrus SASL is an implementation of SASL that makes it easy for application developers to integrate authentication mechanisms into their application in a generic way.")

    add_urls("https://github.com/cyrusimap/cyrus-sasl/releases/download/cyrus-sasl-$(version)/cyrus-sasl-$(version).tar.gz")
    add_versions("2.1.27", "26866b1549b00ffd020f188a43c258017fa1c382b3ddadd8201536f72efb05d5")

    on_install("linux", "macosx", function (package)
        local configs = {"--disable-macos-framework", "--disable-sample"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("sasl_version", {includes = "sasl/sasl.h"}))
    end)
