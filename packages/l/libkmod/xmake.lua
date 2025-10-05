package("libkmod")
    set_homepage("https://github.com/kmod-project/kmod")
    set_description("libkmod - Linux kernel module handling")
    set_license("LGPL-2.1")

    add_urls("https://github.com/kmod-project/kmod/archive/refs/tags/$(version).tar.gz",
             "https://github.com/kmod-project/kmod.git")

    add_versions("v34", "cb47be49366b596e4554eeeb7595b128feb261619c7675603e004b07c5ebbd5b")
    add_versions("v33", "c72120a2582ae240221671ddc1aa53ee522764806f50f8bf1522bbf055679985")
    add_versions("v32", "9477fa096acfcddaa56c74b988045ad94ee0bac22e0c1caa84ba1b7d408da76e")
    add_versions("v31", "16c40aaa50fc953035b4811b29ce3182f220e95f3c9e5eacb4b07b1abf85f003")
    add_versions("v30", "1fa3974abd80b992d61324bcc04fa65ea96cfe2e9e1150f48394833030c4b583")

    -- "--enable-static" is not supported by kmod
    add_configs("shared",  {description = "Build shared library", default = true, type = "boolean", readonly = true})

    add_configs("logging", {description = "Enable system logging.", default = true, type = "boolean"})
    add_configs("zstd",    {description = "Enable Zstandard-compressed modules support.", default = true, type = "boolean"})
    add_configs("zlib",    {description = "Enable gzipped modules support.", default = true, type = "boolean"})
    add_configs("xz",      {description = "Enable Xz-compressed modules support.", default = true, type = "boolean"})
    add_configs("openssl", {description = "Enable PKCS7 signatures support", default = "openssl3", values = {false, "openssl", "openssl3"}})

    add_includedirs("include", "include/libkmod")

    on_check("android", function (package)
        -- bionic, fread_unlocked
        if package:version():ge("v34") then
            local ndk_sdkver = package:toolchain("ndk"):config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) >= 28, "package(libkmod): require ndk api level >= 28")
        end
    end)

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

    on_install("linux", "android@linux,macosx", function (package)
        if package:is_plat("android") then
            local ndk_sdkver = package:toolchain("ndk"):config("ndk_sdkver")
            if package:version():lt("v33") and tonumber(ndk_sdkver) <= 23 then
                io.replace("shared/util.h", "#include <time.h>", [[
                    #include <time.h>
                    #include <string.h>

                    // from libkmod v33
                    static inline const char *basename(const char *s)
                    {
                        const char *p = strrchr(s, '/');
                        return p ? p + 1 : s;
                    }
                ]], {plain = true})
            end
            io.replace("shared/util.h", "#include <time.h>", [[
                #include <time.h>
                #include <unistd.h>

                // from https://android.googlesource.com/kernel/common/+/03c04a7cba972/tools/perf/util/get_current_dir_name.c
                static inline char *get_current_dir_name(void)
                {
                    char pwd[PATH_MAX];
                    return getcwd(pwd, sizeof(pwd)) == NULL ? NULL : strdup(pwd);
                }
            ]], {plain = true})
        end

        if package:version():lt("v34") then
            local configs = {
                "--disable-dependency-tracking",
                "--disable-manpages",
                "--disable-test-modules",
                "--disable-tools"
            }

            table.insert(configs, "--enable-logging=" .. (package:config("logging") and "yes" or "no"))
            table.insert(configs, "--with-zstd=" .. (package:config("zstd") and "yes" or "no"))
            table.insert(configs, "--with-zlib=" .. (package:config("zlib") and "yes" or "no"))
            table.insert(configs, "--with-xz=" .. (package:config("xz") and "yes" or "no"))
            table.insert(configs, "--with-openssl=" .. (package:config("openssl") and "yes" or "no"))

            local packagedeps = {}
            for _, dep in ipairs(package:librarydeps()) do
                table.insert(packagedeps, dep:name())
            end

            io.replace("Makefile.am", [[dist_bashcompletion_DATA = \
	shell-completion/bash/kmod]], "", {plain = true})

            import("package.tools.autoconf").configure(package, configs, {packagedeps = packagedeps})

            io.replace("libtool", "      -all-static)", [[      --target=* )
        func_append compiler_flags " $arg"
        func_append linker_flags " $arg"
        ;;
      -all-static)]], {plain = true})

            os.vrunv("make")
            os.vrunv("make install")
        else
            local configs = {
                "-Dbashcompletiondir=no",
                "-Dfishcompletiondir=no",
                "-Dzshcompletiondir=no",
                "-Dmanpages=false",
                "-Dtools=false"
            }

            table.insert(configs, "-Dlogging=" .. (package:config("logging") and "true" or "false"))
            table.insert(configs, "-Dzstd=" .. (package:config("zstd") and "enabled" or "disabled"))
            table.insert(configs, "-Dzlib=" .. (package:config("zlib") and "enabled" or "disabled"))
            table.insert(configs, "-Dxz=" .. (package:config("xz") and "enabled" or "disabled"))
            table.insert(configs, "-Dopenssl=" .. (package:config("openssl") and "enabled" or "disabled"))

            io.replace("meson.build", "_tools = %[(.-)%]", "_tools = []")

            import("package.tools.meson").install(package, configs)
        end
        os.mv(path.join(package:installdir("include"), "libkmod.h"), path.join(package:installdir("include/libkmod"), "libkmod.h"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("kmod_new", {includes = "libkmod.h"}))
        assert(package:has_cfuncs("kmod_new", {includes = "libkmod/libkmod.h"}))
    end)
