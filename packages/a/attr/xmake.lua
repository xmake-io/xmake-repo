package("attr")

    set_homepage("https://savannah.nongnu.org/projects/attr")
    set_description("Commands for Manipulating Filesystem Extended Attributes")
    set_license("GPL-2.0")

    add_urls("http://download.savannah.nongnu.org/releases/attr/attr-$(version).tar.gz")
    add_versions("2.5.1", "bae1c6949b258a0d68001367ce0c741cebdacdd3b62965d17e5eb23cd78adaf8")

    on_install("linux", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package)
        print(os.files(package:installdir("**")))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("attr_copy_file", {includes = "attr/libattr.h"}))
    end)
