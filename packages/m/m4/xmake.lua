package("m4")

    set_kind("binary")
    set_homepage("https://www.gnu.org/software/m4")
    set_description("Macro processing language")

    add_urls("https://ftpmirror.gnu.org/m4/m4-$(version).tar.xz",
             "https://ftp.gnu.org/gnu/m4/m4-$(version).tar.xz",
             "https://mirrors.ustc.edu.cn/gnu/m4/m4-$(version).tar.xz")
    add_versions("1.4.18", "f2c1e86ca0a404ff281631bdc8377638992744b175afb806e25871a24a934e07")
    add_versions("1.4.19", "63aede5c6d33b6d9b13511cd0be2cac046f2e70fd0a07aa9573a04a82783af96")

    if is_host("macosx") then
        -- fix crash from usage of %n in dynamic format strings on High Sierra
        -- patch credit to Jeremy Huddleston Sequoia <jeremyhu@apple.com>
        add_patches("1.4.18", path.join(os.scriptdir(), "patches", "1.4.18", "secure_snprintf.patch"), "c0a408fbffb7255fcc75e26bd8edab116fc81d216bfd18b473668b7739a4158e")
    elseif is_host("linux") then
        add_extsources("apt::m4", "pacman::m4")
    end

    on_install("@macosx", "@linux", "@msys", "@cygwin", "@bsd", function (package)
        if package:is_plat("linux") then
            -- fix freadahead.c:92:3: error: #error "Please port gnulib freadahead.c to your platform! Look at the definition of fflush, fread, ungetc on your system, then report this to bug-gnulib."
            -- https://git.savannah.gnu.org/cgit/gnulib.git
            for _, gnulib_file in ipairs(os.files("lib/*.c")) do
                io.replace(gnulib_file, "defined _IO_ftrylockfile", "defined _IO_EOF_SEEN || defined _IO_ftrylockfile")
            end
            local file = io.open("lib/stdio-impl.h", "a+")
            file:write([[
#if defined _IO_EOF_SEEN
# if !defined _IO_UNBUFFERED
#  define _IO_UNBUFFERED 0x2
# endif
# if !defined _IO_IN_BACKUP
#  define _IO_IN_BACKUP 0x100
# endif
#endif]])
            file:close()
        end
        import("package.tools.autoconf").install(package, {"--disable-dependency-tracking"})
    end)

    on_test(function (package)
        os.vrun("m4 --version")
    end)
