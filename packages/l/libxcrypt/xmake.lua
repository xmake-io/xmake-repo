package("libxcrypt")
    set_homepage("https://github.com/besser82/libxcrypt")
    set_description("Extended crypt library for descrypt, md5crypt, bcrypt, and others.")
    set_license("GPL-2.0-or-later")

    set_urls("https://github.com/besser82/libxcrypt/releases/download/v$(version)/libxcrypt-$(version).tar.xz")
    add_versions("4.5.2", "71513a31c01a428bccd5367a32fd95f115d6dac50fb5b60c779d5c7942aec071")
    add_versions("4.4.38", "80304b9c306ea799327f01d9a7549bdb28317789182631f1b54f4511b4206dd6")

    add_configs("largefile",           {description = "Enable support for large files.", default = true, type = "boolean"})
    add_configs("failure_tokens",      {description = "Make crypt and crypt_r return NULL on failure.", default = true, type = "boolean"})
    add_configs("xcrypt_compat_files", {description = "Enable installation of compatibility headers/libraries/symlinks.", default = true, type = "boolean"})
    add_configs("obsolete_api",        {description = "Enable all compatibility APIs, or only some.", default = "all", type = "string", values = {"all", "none", "alt", "glibc", "owl", "suse"}})
    add_configs("obsolete_api_enosys", {description = "Enable stub-only compatibility API with no real functionality.", default = false, type = "boolean"})
    add_configs("hashes",              {description = "Select the hashing method to enable.", default = "all", type = "string"})
    add_configs("year2038",            {description = "Enable support for timestamps after 2038.", default = true, type = "boolean"})

    if is_plat("mingw", "msys", "cygwin") then
        add_configs("symvers", {description = "Enable library symbol versioning. (true => auto)", default = false, type = "boolean", readonly = true})
    else
        add_configs("symvers", {description = "Enable library symbol versioning. (true => auto)", default = true, type = "boolean"})
    end

    on_install("linux", "bsd", "macosx", "mingw", "msys", "cygwin", function (package)
        local configs = {
            "--disable-dependency-tracking"
        }

        local features_boolean = {
            "largefile", "symvers", "failure-tokens", "xcrypt-compat-files",
            "obsolete-api-enosys", "year2038"
        }
        for _, feature in ipairs(features_boolean) do
            local yes = package:config(feature:gsub("-", "_"))
            table.insert(configs, ("--enable-%s=%s"):format(feature, yes and "yes" or "no"))
        end

        local obsolete_api = package:config("obsolete_api")
        if obsolete_api == "all" then
            obsolete_api = "yes"
        elseif obsolete_api == "none" then
            obsolete_api = "no"
        end
        table.insert(configs, "--enable-obsolete-api=" .. obsolete_api)
        table.insert(configs, "--enable-hashes=" .. package:config("hashes"))

        if package:is_plat("mingw", "msys", "cygwin") then
            io.replace("Makefile.in", "libcrypt_la_LDFLAGS = -version-info", "libcrypt_la_LDFLAGS = -no-undefined -version-info", {plain = true})
        end

        io.replace("configure", "-Wpedantic", "", {plain = true})
        table.insert(configs, "--enable-werror=no")

        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("crypt", {includes = {"crypt.h"}}))
    end)
