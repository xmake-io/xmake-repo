package("xmlto")
    set_kind("binary")
    set_homepage("https://pagure.io/xmlto")
    set_description("Convert XML to another format (based on XSL or other tools)")
    set_license("GPL-2.0")

    add_urls("https://releases.pagure.org/xmlto/xmlto-$(version).tar.bz2",
             "https://pagure.io/xmlto.git")
    add_versions("0.0.28", "1130df3a7957eb9f6f0d29e4aa1c75732a7dfb6d639be013859b5c7ec5421276")

    add_deps("flex", {kind = "binary"})
    add_deps("util-linux")

    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf")

        io.replace("xmlif/xmlif.l",[[static ifsense;]],[[static int ifsense;]],{plain = true})
        io.replace("xmlif/xmlif.l",[[main(int argc, char *argv[])]],[[int main(int argc, char *argv[])]],{plain = true})

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
