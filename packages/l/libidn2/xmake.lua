package("libidn2")

    set_homepage("https://www.gnu.org/software/libidn/")
    set_description("Libidn2 is an implementation of the IDNA2008 + TR46 specifications.")
    set_license("LGPL-3.0")

    add_urls("https://ftpmirror.gnu.org/gnu/libidn/libidn2-$(version).tar.gz",
             "https://ftp.gnu.org/gnu/libidn/libidn2-$(version).tar.gz")
    add_versions("2.3.2", "76940cd4e778e8093579a9d195b25fff5e936e9dc6242068528b437a76764f91")
    add_versions("2.3.8", "f557911bf6171621e1f72ff35f5b1825bb35b52ed45325dcdee931e5d3c0787a")

    if is_plat("linux") then
        add_extsources("apt::libidn2-dev", "pacman::libidn2")
    end

    on_load(function (package)
        package:add("deps", "libunistring", "libiconv", { configs = {shared = package:config("shared")} })
    end)

    on_install("@!windows and !wasm", function (package)
        local configs = {"--disable-dependency-tracking", "--disable-doc"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs, {packagedeps = {"libunistring", "libiconv"}})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("idn2_to_ascii_8z", {includes = "idn2.h"}))
    end)
