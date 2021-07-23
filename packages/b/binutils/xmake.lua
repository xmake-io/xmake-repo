package("binutils")

    set_homepage("https://www.gnu.org/software/binutils/binutils.html")
    set_description("GNU binary tools for native development")
    set_license("GPL-2.0")

    set_kind("binary")
    set_urls("https://ftp.gnu.org/gnu/binutils/binutils-$(version).tar.xz",
             "https://ftpmirror.gnu.org/binutils/binutils-$(version).tar.xz")

    add_versions("2.34", "f00b0e8803dc9bab1e2165bd568528135be734df3fabf8d0161828cd56028952")

    on_install("@linux", "@macosx", "@msys", function (package)
        local configs = {"--disable-debug",
                          "--disable-dependency-tracking",
                          "--enable-deterministic-archives",
                          "--infodir=" .. package:installdir("share/info"),
                          "--mandir=" .. package:installdir("share/man"),
                          "--disable-werror",
                          "--enable-interwork",
                          "--enable-multilib",
                          "--enable-64-bit-bfd",
                          "--enable-targets=all"}
        if package:is_plat("linux") then
            table.insert(configs, "--with-sysroot=/")
            table.insert(configs, "--enable-gold")
            table.insert(configs, "--enable-plugins")
        end
        -- fix 'makeinfo' is missing on your system.
        io.replace("binutils/Makefile.in", "SUBDIRS = doc po", "SUBDIRS = ")
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        os.vrun("strings --version")
    end)
