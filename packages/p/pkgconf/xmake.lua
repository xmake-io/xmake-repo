package("pkgconf")

    set_kind("binary")
    set_homepage("http://pkgconf.org")
    set_description("A program which helps to configure compiler and linker flags for development frameworks.")

    add_urls("https://distfiles.dereferenced.org/pkgconf/pkgconf-$(version).tar.xz")
    add_versions("1.7.4", "d73f32c248a4591139a6b17777c80d4deab6b414ec2b3d21d0a24be348c476ab")
    add_versions("1.8.0", "ef9c7e61822b7cb8356e6e9e1dca58d9556f3200d78acab35e4347e9d4c2bbaf")
    add_versions("1.9.3", "5fb355b487d54fb6d341e4f18d4e2f7e813a6622cf03a9e87affa6a40565699d")

    on_load(function (package)
        if not package:is_precompiled() and is_host("windows") then
            package:add("deps", "meson", "ninja")
        end
    end)

    on_install("@macosx", "@linux", "@bsd", function(package)
        import("package.tools.autoconf").install(package)
    end)

    on_install("@windows", function(package)
        import("package.tools.meson").install(package, {"-Dtests=false"})
        local bindir = package:installdir("bin")
        os.cp(path.join(bindir, "pkgconf.exe"), path.join(bindir, "pkg-config.exe"))
    end)

    on_test(function (package)
        os.vrun("pkgconf --version")
        if is_subhost("windows") then
            os.vrun("pkg-config --version")
        end
    end)
