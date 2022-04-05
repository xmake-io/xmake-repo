package("binutils")

    set_kind("binary")
    set_homepage("https://www.gnu.org/software/binutils/binutils.html")
    set_description("GNU binary tools for native development")
    set_license("GPL-2.0")

    set_urls("https://ftp.gnu.org/gnu/binutils/binutils-$(version).tar.xz",
             "https://ftpmirror.gnu.org/binutils/binutils-$(version).tar.xz")
    add_versions("2.38", "e316477a914f567eccc34d5d29785b8b0f5a10208d36bbacedcc39048ecfe024")
    add_versions("2.34", "f00b0e8803dc9bab1e2165bd568528135be734df3fabf8d0161828cd56028952")
    
    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::binutils")
    elseif is_plat("linux") then
        add_extsources("pacman::binutils", "apt::binutils")
    elseif is_plat("macosx") then
        add_extsources("brew::binutils")
    end

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
        io.replace("binutils/Makefile.in", "SUBDIRS =[^\n]-po", "SUBDIRS =")
        io.replace("gas/Makefile.in", "INFO_DEPS =[^\n]-%.info", "INFO_DEPS =")
        if package:version():le("2.34") then
            -- fix multiple definition of `program_name'
            io.replace("binutils/srconv.c", "char *program_name;", "extern char *program_name;", {plain = true})
            io.replace("binutils/sysdump.c", "char *program_name;", "extern char *program_name;", {plain = true})
            io.replace("binutils/coffdump.c", "char * program_name;", "extern char *program_name;", {plain = true})
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        os.vrun("strings --version")
    end)
