package("pkg-config")

    set_kind("binary")
    set_homepage("https://freedesktop.org/wiki/Software/pkg-config/")
    set_description("A helper tool used when compiling applications and libraries.")

    if is_host("macosx", "linux") then
        add_urls("https://pkgconfig.freedesktop.org/releases/pkg-config-$(version).tar.gz", {alias = "freedesktop"})
        add_urls("https://github.com/xmake-mirror/pkg-config/archive/pkg-config-$(version).tar.gz", {alias = "github"})
        add_urls("https://gitlab.com/xmake-mirror/pkg-config/-/archive/pkg-config-$(version)/pkg-config-pkg-config-$(version).tar.gz", {alias = "gitlab"})
        add_urls("https://gitlab.freedesktop.org/pkg-config/pkg-config.git")
        add_versions("freedesktop:0.29.2", "6fc69c01688c9458a57eb9a1664c9aba372ccda420a02bf4429fe610e7e7d591")
        add_versions("github:0.29.2", "67d89af4777653f81f18a6c42620fb51536fea469d412c932b9c7a411f62458a")
        add_versions("gitlab:0.29.2", "67d89af4777653f81f18a6c42620fb51536fea469d412c932b9c7a411f62458a")
    end

    on_install("macosx", "linux", function (package)
        local pcpath = {"/usr/local/lib/pkgconfig", "/usr/lib/pkgconfig"}
        if is_host("macosx") then
            table.insert(pcpath, "/usr/local/Homebrew/Library/Homebrew/os/mac/pkgconfig/" .. macos.version():major() .. '.' .. macos.version():minor())
        end
        import("package.tools.autoconf").install(package, {"--disable-debug", "--disable-host-tool", "--with-internal-glib", ["with-pc-path"] = table.concat(pcpath, ':')})
    end)

    on_test(function (package)
        os.vrun("pkg-config --version")
    end)
