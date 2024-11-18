package("pkg-config")
    set_kind("binary")
    set_homepage("https://freedesktop.org/wiki/Software/pkg-config/")
    set_description("A helper tool used when compiling applications and libraries.")

    if is_host("macosx", "linux", "bsd") then
        add_urls("https://pkgconfig.freedesktop.org/releases/pkg-config-$(version).tar.gz")
        add_urls("http://fresh-center.net/linux/misc/pkg-config-$(version).tar.gz")
        add_versions("0.29.2", "6fc69c01688c9458a57eb9a1664c9aba372ccda420a02bf4429fe610e7e7d591")
    end

    if is_subhost("msys") then
        add_deps("pacman::pkg-config")
    end

    on_install("@msys", function (package)
    end)

    on_install("@macosx", "@linux", "@bsd", function (package)
        local pcpath = {"/usr/local/lib/pkgconfig", "/usr/lib/pkgconfig"}
        if package:is_plat("linux") and package:is_arch("x86_64") then
            table.insert(pcpath, "/usr/lib64/pkgconfig")
            table.insert(pcpath, "/usr/lib/x86_64-linux-gnu/pkgconfig")
        end
        if is_host("macosx") then
            table.insert(pcpath, "/usr/local/Homebrew/Library/Homebrew/os/mac/pkgconfig/" .. macos.version():major() .. '.' .. macos.version():minor())
        end
        -- see https://gitlab.freedesktop.org/pkg-config/pkg-config/-/issues/81
        local opt = {cflags = "-Wno-int-conversion"}
        import("package.tools.autoconf").install(package, {"--disable-werror", "--disable-compile-warnings", "--disable-debug", "--disable-host-tool", "--with-internal-glib", ["with-pc-path"] = table.concat(pcpath, ':')}, opt)
    end)

    on_test(function (package)
        os.vrun("pkg-config --version")
    end)
