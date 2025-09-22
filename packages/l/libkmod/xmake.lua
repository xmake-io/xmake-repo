package("libkmod")
    set_homepage("https://github.com/kmod-project/kmod")
    set_description("libkmod - Linux kernel module handling")
    set_license("LGPL-2.1")

    add_urls("https://github.com/kmod-project/kmod/archive/refs/tags/$(version).tar.gz",
             "https://github.com/kmod-project/kmod.git")

    add_versions("v33", "c72120a2582ae240221671ddc1aa53ee522764806f50f8bf1522bbf055679985")
    add_versions("v32", "9477fa096acfcddaa56c74b988045ad94ee0bac22e0c1caa84ba1b7d408da76e")
    add_versions("v31", "16c40aaa50fc953035b4811b29ce3182f220e95f3c9e5eacb4b07b1abf85f003")
    add_versions("v30", "1fa3974abd80b992d61324bcc04fa65ea96cfe2e9e1150f48394833030c4b583")

    add_patches(">=30 <33", path.join(os.scriptdir(), "patches", "31", "basename.patch"), "83d07e169882cc91f3af162912ae97cd4b62ff48876ca83b0317c40a388773ad")

    -- "--enable-static" is not supported by kmod
    add_configs("shared", {description = "Build shared library", default = true, type = "boolean", readonly = true})

    add_configs("tools",     {description = "Build tools.", default = false, type = "boolean"})
    add_configs("logging",   {description = "Enable system logging.", default = true, type = "boolean"})

    add_configs("zstd",    {description = "Enable Zstandard-compressed modules support.", default = true, type = "boolean"})
    add_configs("zlib",    {description = "Enable gzipped modules support.", default = false, type = "boolean"})
    add_configs("xz",      {description = "Enable Xz-compressed modules support.", default = true, type = "boolean"})
    add_configs("openssl", {description = "Enable PKCS7 signatures support", default = "openssl3", values = {false, "openssl", "openssl3"}})

    on_load(function (package)
        if package:version():lt("v34") then
            package:add("deps", "autotools")
        else
            package:add("deps", "meson", "ninja")
        end

        for _, lib in ipairs({"zstd", "zlib", "xz"}) do
            if package:config(lib) then
                package:add("deps", lib)
            end
        end
        local openssl = package:config("openssl")
        if openssl then
            package:add("deps", openssl)
        end
    end)

    on_install("linux", "android", function (package)
        if package:version():lt("v34") then
            local configs = {
                "--disable-dependency-tracking",
                "--disable-manpages",
                "--disable-test-modules"
            }

            table.insert(configs, "--enable-tools=" .. (package:config("tools") and "yes" or "no"))
            table.insert(configs, "--enable-logging=" .. (package:config("logging") and "yes" or "no"))

            table.insert(configs, "--with-zstd=" .. (package:config("logging") and "yes" or "no"))
            table.insert(configs, "--with-zlib=" .. (package:config("logging") and "yes" or "no"))
            table.insert(configs, "--with-xz=" .. (package:config("logging") and "yes" or "no"))
            table.insert(configs, "--with-openssl=" .. (package:config("logging") and "yes" or "no"))

            io.replace("Makefile.am", [[dist_bashcompletion_DATA = \
	shell-completion/bash/kmod]], "", {plain = true})

            import("package.tools.autoconf").install(package, configs)
        else
            local configs = {
                "-Dbashcompletiondir=no",
                "-Dfishcompletiondir=no",
                "-Dzshcompletiondir=no",
                "-Dmanpages=false"
            }

            table.insert(configs, "-Dtools=" .. (package:config("tools") and "true" or "false"))
            table.insert(configs, "-Dlogging=" .. (package:config("logging") and "true" or "false"))

            table.insert(configs, "-Dzstd=" .. (package:config("logging") and "enabled" or "disabled"))
            table.insert(configs, "-Dzlib=" .. (package:config("logging") and "enabled" or "disabled"))
            table.insert(configs, "-Dxz=" .. (package:config("logging") and "enabled" or "disabled"))
            table.insert(configs, "-Dopenssl=" .. (package:config("logging") and "enabled" or "disabled"))

            io.replace("meson.build", "dependency(pkg_dep, ", "dependency(pkg_dep, method : 'pkg-config', ", {plain = true})

            import("package.tools.meson").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("kmod_new", {includes = "libkmod.h"}))
    end)
