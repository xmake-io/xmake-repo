package("libsystemd")
    set_homepage("https://systemd.io")
    set_description("The systemd System and Service Manager.")

    add_urls("https://github.com/systemd/systemd/archive/refs/tags/$(version).tar.gz",
             "https://github.com/systemd/systemd.git")

    add_versions("v259", "a84123692d1add7f9c48fd11cdf5f901393008c2d2ade667c18f25a20bf1290d")
    add_versions("v258.2", "05208e76bf1f9b369b1a8159e6631ef67c82f2d27c21e931962026a79bf4ba64")
    add_versions("v258.1", "8eb34eaf2f78330217280bd7a923578f37e28d3f3ac5168e336ebc9cad84a34d")
    add_versions("v258", "07a580cf21856f468f82b77b82973a926f42ccc696462459b53f8b88893dff8e")

    add_configs("udev", {description = "Build libudev.", default = true, type = "boolean"})

    add_configs("acl",      {description = "Enable libacl support.", default = true, type = "boolean"})
    add_configs("audit",    {description = "Enable libaudit support.", default = true, type = "boolean"})
    add_configs("blkid",    {description = "Enable libblkid support.", default = true, type = "boolean"})
    add_configs("kmod",     {description = "Enable support for loadable modules.", default = true, type = "boolean"})
    add_configs("pam",      {description = "Enable PAM support.", default = true, type = "boolean"})
    add_configs("gcrypt",   {description = "Enable gcrypt support.", default = true, type = "boolean"})
    add_configs("openssl",  {description = "Enable openssl support.", default = "openssl3", type = "string", values = {false, "openssl", "openssl3"}})
    add_configs("p11kit",   {description = "Enable p11kit support.", default = true, type = "boolean"})
    add_configs("xz",       {description = "Enable xz compression support.", default = true, type = "boolean"})
    add_configs("lz4",      {description = "Enable lz4 compression support.", default = true, type = "boolean"})
    add_configs("zstd",     {description = "Enable zstd compression support.", default = true, type = "boolean"})
    add_configs("libmount", {description = "Enable lib support", default = true, type = "boolean"})

    add_configs("seccomp", {description = "Enable SECCOMP support.", default = true, type = "boolean"})
    add_configs("selinux", {description = "Enable SELinux support.", default = true, type = "boolean"})

    add_deps("python", {kind = "binary"})
    add_deps("libcap", "libxcrypt")
    on_load(function(package)
        if package:config("udev") then
            package:add("syslinks", "rt", "pthread")
        end

        function install_deps(opt, dep)
            dep = dep or opt
            if package:config(opt) then
                package:add("deps", dep)
            end
        end

        install_deps("acl")
        install_deps("audit")
        install_deps("kmod", "libkmod")
        install_deps("pam", "libpam")
        install_deps("gcrypt", "libgcrypt")
        install_deps("p11kit", "p11-kit")
        install_deps("xz")
        install_deps("lz4")
        install_deps("zstd")

        install_deps("seccomp", "libseccomp")
        install_deps("selinux", "libselinux")

        local openssl = package:config("openssl")
        if openssl and openssl ~= "disabled" then
            package:add("deps", openssl)
        end

        local util_linux_cfg = {}
        if package:config("blkid") then
            util_linux_cfg.libblkid = true
        end
        if package:config("libmount") then
            util_linux_cfg.libmount = true
        end
        if not table.empty(util_linux_cfg) then
            package:add("deps", "util-linux", {configs = util_linux_cfg})
        end
    end)

    on_install("linux", function (package)
        local buildscript = ""
        for _, line in ipairs(io.readfile("meson.build"):split("\n")) do
            if not line:startswith("runtest_env = custom_target(") then
                buildscript = buildscript .. line .. "\n"
            else
                break
            end
        end
        buildscript = buildscript:gsub("subdir%('catalog'%)", "")
        buildscript = buildscript:gsub("subdir%('po'%)", "")

        buildscript = buildscript:gsub("libsystemd = shared_library", "if static_libsystemd == 'false'\nlibsystemd = shared_library")
        buildscript = buildscript:gsub("libudev = shared_library", "if static_libudev == 'false'\nlibudev = shared_library")
        buildscript = buildscript:gsub("install_dir : libdir%)", "install_dir : libdir) endif")
        buildscript = buildscript:gsub("alias_target%b()", "")

        buildscript = buildscript .. "subdir('src/systemd')\n"

        if not package:config("udev") then
            buildscript = buildscript:gsub("subdir%('src/libudev'%)", "")
            buildscript = buildscript:gsub("static_libudev == 'false'", "false")
            buildscript = buildscript:gsub("static_libudev != 'false'", "false")
        end

        io.writefile("meson.build", buildscript)

        local configs = {"-Dtests=false"}

        table.insert(configs, "-Dmode=" .. (package:is_debug() and "developer" or "release"))
        if package:config("shared") then
            table.insert(configs, "-Dstatic-libsystemd=false")
            table.insert(configs, "-Dstatic-libudev=false")
        else
            table.insert(configs, "-Dstatic-libsystemd=" .. (package:config("pic") and "pic" or "no-pic"))
            table.insert(configs, "-Dstatic-libudev=" .. (package:config("pic") and "pic" or "no-pic"))
        end

        local sd_configs = {
            "acl", "audit", "blkid", "kmod", "pam", "gcrypt", "p11kit", "xz", "lz4", "zstd"
        }
        for _, sd_config in ipairs(sd_configs) do
            table.insert(configs, "-D" .. sd_config .. "=" .. (package:config(sd_config) and "enabled" or "disabled"))
        end

        io.replace("src/shared/meson.build", "install : true,", "build_by_default : false,", {plain = true})

        os.vrun("python -m pip install jinja2")

        local packagedeps = {"libcap"}
        if package:config("audit") then
            table.insert(packagedeps, "audit")
        end
        if package:config("gcrypt") then
            table.insert(packagedeps, "libgcrypt")
            table.insert(packagedeps, "libgpg-error")
        end

        local cflags = {}
        if package:config("kmod") then
            local info = package:dep("libkmod"):fetch()
            for _, includedir in ipairs(info.includedirs or info.sysincludedirs) do
                table.insert(cflags, "-I" .. includedir)
            end
        end

        import("package.tools.meson").install(package, configs, {packagedeps = packagedeps, cflags = cflags})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("sd_watchdog_enabled", {includes = "systemd/sd-daemon.h"}))
        if package:config("udev") then
            assert(package:has_cfuncs("udev_new", {includes = "libudev.h"}))
        end
    end)
