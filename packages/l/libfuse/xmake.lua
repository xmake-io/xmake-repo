package("libfuse")

    set_homepage("https://github.com/libfuse/libfuse")
    set_description("FUSE (Filesystem in Userspace) is an interface for userspace programs to export a filesystem to the Linux kernel.")
    set_license("GPL-2.0")

    add_urls("https://github.com/libfuse/libfuse/releases/download/fuse-$(version)/fuse-$(version).tar.xz")
    add_versions("3.10.4", "9365b74fd8471caecdb3cc5adf25a821f70a931317ee9103d15bd39089e3590d")

    if is_plat("linux") then
        add_extsources("apt::fuse3", "pacman::fuse3")
        add_syslinks("pthread", "dl", "rt")
    end

    add_deps("meson")
    on_install("linux", function (package)
        local configs = {"-Dtests=false", "-Dexamples=false", "-Dutils=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("fuse_version", {configs = {defines = {"FUSE_USE_VERSION=30"}}, includes = "fuse3/fuse.h"}))
    end)
