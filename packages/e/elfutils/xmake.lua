package("elfutils")

    set_homepage("https://fedorahosted.org/elfutils/")
    set_description("Libraries and utilities for handling ELF objects")
    set_license("GPL-2.0")

    set_urls("https://sourceware.org/elfutils/ftp/$(version)/elfutils-$(version).tar.bz2")
    add_versions("0.183", "c3637c208d309d58714a51e61e63f1958808fead882e9b607506a29e5474f2c5")

    add_patches("0.183", path.join(os.scriptdir(), "patches", "0.183", "configure.patch"), "7a16719d9e3d8300b5322b791ba5dd02986f2663e419c6798077dd023ca6173a")

    add_deps("m4", "zlib")
    if is_plat("android") then
        add_deps("libintl")
    end

    on_install("linux", "android", function (package)
        local configs = {"--disable-dependency-tracking",
                         "--disable-silent-rules",
                         "--program-prefix=elfutils-",
                         "--disable-symbol-versioning",
                         "--disable-debuginfod",
                         "--disable-libdebuginfod"}
        local cflags = {}
        if package:config("pic") ~= false then
            table.insert(cflags, "-fPIC")
        end
        for _, makefile in ipairs(os.files(path.join("*/Makefile.in"))) do
            io.replace(makefile, "-Wtrampolines", "", {plain = true})
            io.replace(makefile, "-Wimplicit-fallthrough=5", "", {plain = true})
        end
        import("package.tools.autoconf").install(package, configs, {cflags = cflags, packagedeps = "zlib"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("elf_begin", {includes = "gelf.h"}))
    end)
