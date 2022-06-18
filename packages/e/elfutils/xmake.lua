package("elfutils")

    set_homepage("https://fedorahosted.org/elfutils/")
    set_description("Libraries and utilities for handling ELF objects")
    set_license("GPL-2.0")

    set_urls("https://sourceware.org/elfutils/ftp/$(version)/elfutils-$(version).tar.bz2")
    add_versions("0.183", "c3637c208d309d58714a51e61e63f1958808fead882e9b607506a29e5474f2c5")

    add_patches("0.183", path.join(os.scriptdir(), "patches", "0.183", "configure.patch"), "7a16719d9e3d8300b5322b791ba5dd02986f2663e419c6798077dd023ca6173a")

    add_configs("libelf",   {description = "Enable libelf", default = true, type = "boolean"})
    add_configs("libcpu",   {description = "Enable libcpu", default = false, type = "boolean"})
    add_configs("libebl",   {description = "Enable libebl", default = false, type = "boolean"})
    add_configs("libdw",    {description = "Enable libdw", default = false, type = "boolean"})
    add_configs("libdwelf", {description = "Enable libdwelf", default = false, type = "boolean"})
    add_configs("libdwfl",  {description = "Enable libdwfl", default = false, type = "boolean"})
    add_configs("libasm",   {description = "Enable libasm", default = false, type = "boolean"})

    add_deps("m4", "zlib")
    if is_plat("android") then
        add_deps("libintl", "argp-standalone")
    end

    if is_plat("android") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
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
            if package:has_tool("cc", "clang") then
                io.replace(makefile, "-Wno-packed-not-aligned", "", {plain = true})
            end
        end
        local subdirs = {}
        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                if enabled then
                    table.insert(subdirs, name)
                end
            end
        end
        io.replace("Makefile.in", [[SUBDIRS = config lib libelf libcpu backends libebl libdwelf libdwfl libdw \
	  libasm debuginfod src po doc tests]], "SUBDIRS = lib " .. table.concat(subdirs, " "), {plain = true})

        if package:is_plat("android") then
            io.replace("libelf/Makefile.in", "-Wl,--whole-archive $(libelf_so_LIBS) -Wl,--no-whole-archive", "$(libelf_so_LIBS)", {plain = true})
            io.replace("libdw/Makefile.in", "-Wl,--whole-archive $(libdw_so_LIBS) -Wl,--no-whole-archive", "$(libdw_so_LIBS)", {plain = true})
            io.replace("libasm/Makefile.in", "-Wl,--whole-archive $(libasm_so_LIBS) -Wl,--no-whole-archive", "$(libasm_so_LIBS)", {plain = true})
            table.insert(cflags, "-Wno-error=conditional-type-mismatch")
            table.insert(cflags, "-Wno-error=unused-command-line-argument")
            table.insert(cflags, "-Wno-error=implicit-function-declaration")
            table.insert(cflags, "-Wno-error=int-conversion")
            table.insert(cflags, "-Wno-error=gnu-variable-sized-type-not-at-end")
            table.insert(cflags, '-Dprogram_invocation_short_name=\\\"test\\\"')
            table.insert(cflags, '-D_GNU_SOURCE=1')
            table.insert(cflags, '-Derror_message_count=0')
        end
        import("package.tools.autoconf").install(package, configs, {cflags = cflags,
            packagedeps = {"zlib", "libintl", "argp-standalone"}})
        if package:config("shared") then
            os.rm(path.join(package:installdir("lib"), "*.a"))
        else
            os.rm(path.join(package:installdir("lib"), "*.so"))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("elf_begin", {includes = "gelf.h"}))
    end)
