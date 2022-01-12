package("e2fsprogs")

    set_homepage("http://e2fsprogs.sourceforge.net")
    set_description("Filesystem utilities for the ext2/3/4 filesystems")

    add_urls("https://git.kernel.org/pub/scm/fs/ext2/e2fsprogs.git/snapshot/e2fsprogs-$(version).tar.gz")

    add_versions("1.46.4", "c011bf3bf4ae5efe9fa2b0e9b0da0c14ef4b79c6143c1ae6d9f027931ec7abe1")

    if is_plat("linux") then
        add_extsources("apt::e2fsprogs", "pacman::e2fsprogs")
    elseif is_plat("macosx") then
        add_extsources("brew::e2fsprogs")
    end
    if is_plat("linux") then
        add_syslinks("pthread", "com_err")
    end

    on_install("linux", "macosx", function (package)
        import("package.tools.autoconf")

        os.rm("scrub")
        local configs = {"MKDIR_P=mkdir -p", "--disable-e2initrd-helper"}
        table.insert(configs, "--exec-prefix=" .. package:installdir())
        table.insert(configs, "--enable-libuuid")
        if package:config("shared") then
            if package:is_plat("linux") then
                table.insert(configs, "--enable-elf-shlibs")
            elseif package:is_plat("macosx") then
                table.insert(configs, "--enable-bsd-shlibs")
            end
        end
        -- Enforce MKDIR_P to work around a configure bug
        -- see https://github.com/Homebrew/homebrew-core/pull/35339
        autoconf.build(package, configs)
        -- make V=1 will fail for e2fsprogs, for reasons unknown
        -- So call make manually to ensure V=1 is not specified
        autoconf.make(package, {"install"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ext2fs_open", {includes = "ext2fs/ext2fs.h"}))
        assert(package:has_cfuncs("uuid_parse", {includes = "uuid/uuid.h"}))
    end)
