package("elfutils")

    set_homepage("https://fedorahosted.org/elfutils/")
    set_description("Libraries and utilities for handling ELF objects")
    set_license("GPL-2.0")

    set_urls("https://sourceware.org/elfutils/ftp/$(version)/elfutils-$(version).tar.bz2")
    add_versions("0.183", "c3637c208d309d58714a51e61e63f1958808fead882e9b607506a29e5474f2c5")
    add_versions("0.189", "39bd8f1a338e2b7cd4abc3ff11a0eddc6e690f69578a57478d8179b4148708c8")

    add_patches("0.183", path.join(os.scriptdir(), "patches", "0.183", "configure.patch"), "7a16719d9e3d8300b5322b791ba5dd02986f2663e419c6798077dd023ca6173a")
    add_patches("0.189", path.join(os.scriptdir(), "patches", "0.189", "configure.patch"), "b4016a97e6aaad92b15fad9a594961b1fc77a6d054ebadedef9bb3a55e99a8f8")

    add_configs("libelf",   {description = "Enable libelf", default = true, type = "boolean"})
    add_configs("libdw",    {description = "Enable libdw", default = true, type = "boolean"})
    add_configs("libasm",   {description = "Enable libasm", default = false, type = "boolean"})

    add_deps("m4", "zstd", "zlib")

    if on_source then
        on_source(function (package)
            if package:is_plat("android") then
                package:add("configs", "shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
            end
        end)
    elseif is_plat("android") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    on_load(function(package)
        if package:is_plat("android") then
            package:add("deps", "libintl", "argp-standalone")
        end
    end)

    if on_check then
        -- https://github.com/xmake-io/xmake-repo/issues/3182
        on_check("android", function (package)
            local ndk = package:toolchain("ndk")
            local ndk_sdkver = ndk:config("ndk_sdkver")
            local ndkver = ndk:config("ndkver")
            assert(ndkver and tonumber(ndkver) < 26, "package(elfutils): need ndk version < 26 for android")
            assert(ndk_sdkver and tonumber(ndk_sdkver) <= 23, "package(elfutils): need ndk api level <= 23 for android")
        end)
    end

    on_install("linux", "android", function (package)
        local configs = {"--disable-dependency-tracking",
                         "--disable-silent-rules",
                         "--program-prefix=elfutils-",
                         "--disable-symbol-versioning",
                         "--disable-debuginfod",
                         "--disable-libdebuginfod"}
        local cflags = {}
        for _, makefile in ipairs(os.files(path.join("*/Makefile.in"))) do
            io.replace(makefile, "-Wtrampolines", "", {plain = true})
            io.replace(makefile, "-Wimplicit-fallthrough=5", "", {plain = true})
            io.replace(makefile, "-Werror", "", {plain = true})
            if package:has_tool("cc", "clang") then
                io.replace(makefile, "-Wno-packed-not-aligned", "", {plain = true})
            end
        end
        local subdirs = {}
        if package:config("libelf") then
            table.insert(subdirs, "libelf")
        end
        if package:config("libdw") then
            table.join2(subdirs, "libcpu", "backends", "libebl", "libdwelf", "libdwfl", "libdw")
        end
        if package:config("libasm") then
            table.insert(subdirs, "libasm")
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
        end
        local packagedeps = {"zlib"}
        if package:is_plat("android") then
            table.join2(packagedeps, "libintl", "argp-standalone")
        end
        import("package.tools.autoconf").install(package, configs, {cflags = cflags,
            packagedeps = packagedeps})
        if package:config("shared") then
            os.rm(path.join(package:installdir("lib"), "*.a"))
        else
            os.rm(path.join(package:installdir("lib"), "*.so"))
            os.tryrm(path.join(package:installdir("lib"), "*.so.*"))
        end
        os.trycp("libelf/elf.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("elf_begin", {includes = "gelf.h"}))
    end)
