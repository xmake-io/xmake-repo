package("patchelf")
    set_kind("binary")
    set_homepage("https://github.com/NixOS/patchelf")
    set_description("A small utility to modify the dynamic linker and RPATH of ELF executables")
    set_license("GPL-3.0")

    add_urls("https://github.com/NixOS/patchelf/archive/refs/tags/$(version).tar.gz",
             "https://github.com/NixOS/patchelf.git")

    add_versions("0.18.0", "1451d01ee3a21100340aed867d0b799f46f0b1749680028d38c3f5d0128fb8a7")

    add_deps("autoconf", "automake", "libtool")

    on_install("linux", "bsd", "macosx", function (package)
        local configs = {}
        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        os.run("patchelf --version")
    end)
