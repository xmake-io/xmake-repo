package("libmagic")

    set_homepage("https://www.darwinsys.com/file/")
    set_description("Implementation of the file(1) command")

    add_urls("https://astron.com/pub/file/file-$(version).tar.gz")
    add_versions("5.40", "167321f43c148a553f68a0ea7f579821ef3b11c27b8cbe158e4df897e4a5dd57")

    if is_plat("linux", "bsd") then
        add_deps("zlib")
    end

    on_install("macosx", "linux", "bsd", function (package)
        local configs = {"--disable-dependency-tracking",
                         "--disable-silent-rules",
                         "--disable-xzlib",
                         "--disable-bzlib"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("magic_open", {includes = "magic.h"}))
    end)
