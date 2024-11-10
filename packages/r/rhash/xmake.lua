package("rhash")

    set_homepage("http://rhash.sourceforge.net/")
    set_description("RHash (Recursive Hasher) is a console utility for computing and verifying hash sums of files.")
    
    add_urls("https://sourceforge.net/projects/rhash/files/rhash/$(version)/rhash-$(version)-src.tar.gz")
    add_urls("https://github.com/rhash/RHash/archive/refs/tags/v$(version).tar.gz")
    add_versions("1.4.5", "6db837e7bbaa7c72c5fd43ca5af04b1d370c5ce32367b9f6a1f7b49b2338c09a")
    add_versions("1.4.4", "8e7d1a8ccac0143c8fe9b68ebac67d485df119ea17a613f4038cda52f84ef52a")
    add_versions("1.4.2", "600d00f5f91ef04194d50903d3c79412099328c42f28ff43a0bdb777b00bec62")

    add_configs("gettext", {description = "Enable gettext (localization) support.", default = false, type = "boolean"})
    add_configs("openssl", {description = "Enable OpenSSL (optimized hash functions) support.", default = false, type = "boolean"})

    on_load(function (package)
        if package:config("gettext") and package:is_plat("macosx") then
            package:add("deps", "libintl")
        end
        if package:config("openssl") then
            package:add("deps", "openssl")
        end
    end)

    on_install("linux", function (package)
        io.replace("Makefile", "install-lib-shared: $(LIBRHASH_SHARED)", "install-lib-shared: $(LIBRHASH_SHARED) install-lib-headers install-lib-so-link", {plain = true})
        local configs = {"--disable-openssl-runtime"}
        table.insert(configs, (package:config("shared") and "--enable" or "--disable") .. "-lib-shared")
        table.insert(configs, (package:config("shared") and "--disable" or "--enable") .. "-lib-static")
        table.insert(configs, (package:config("shared") and "--disable" or "--enable") .. "-static")
        table.insert(configs, (package:config("gettext") and "--enable" or "--disable") .. "-gettext")
        table.insert(configs, (package:config("openssl") and "--enable" or "--disable") .. "-openssl")
        import("package.tools.autoconf").install(package, configs)
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        os.vrun("rhash --version")
        assert(package:has_cfuncs("rhash_library_init", {includes = "rhash.h"}))
    end)
