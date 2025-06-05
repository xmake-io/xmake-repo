package("xmlto")

    set_kind("binary")
    set_homepage("https://pagure.io/xmlto")
    set_description("Convert XML to another format (based on XSL or other tools)")
    set_license("GPL-2.0")

    add_urls("https://releases.pagure.org/xmlto/xmlto-$(version).tar.bz2",
             "https://pagure.io/xmlto.git")
    add_versions("0.0.28", "1130df3a7957eb9f6f0d29e4aa1c75732a7dfb6d639be013859b5c7ec5421276")
    add_versions("0.0.29", "6000d8e8f0f9040426c4f85d7ad86789bc88d4aeaef585c4d4110adb0b214f21")

    add_deps("util-linux")
    if not is_plat("windows") then
        add_deps("autoconf", "automake", "libtool")
        add_deps("libxslt", {kind = "binary"})
    end

    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf")
        local envs = autoconf.buildenvs(package)
        local getopt = package:dep("util-linux"):fetch()
        for _, dir in ipairs(getopt.linkdirs) do
            local prefix = path.directory(dir)
            local opt_path = path.join(prefix, "bin", "getopt")
            if os.isfile(opt_path) then
                envs.GETOPT = opt_path
            end
        end
        local config = {"--disable-dependency-tracking"}
        autoconf.install(package, config, {envs = envs})
    end)

    on_test(function (package)
        os.vrun("xmlto --version")
    end)
