package("libpam")
    set_homepage("https://github.com/linux-pam/linux-pam")
    set_description("Pluggable Authentication Modules for Linux")

    add_urls("https://github.com/linux-pam/linux-pam/archive/refs/tags/$(version).tar.gz",
             "https://github.com/linux-pam/linux-pam.git")

    add_versions("v1.7.2", "d7ce5cb6e07ee8603d8af41a672bcb515b9d27079ee309fb3f729a8020166694")
    add_versions("v1.7.1", "82aadd97eb697965b577069c12046a4dd1be68361a9978c708698d2a1ee9b6d1")

    add_configs("i18n",  {description = "Enable i18n support.", default = true, type = "boolean"})
    add_configs("audit", {description = "Enable audit support.", default = true, type = "boolean"})
    add_configs("econf", {description = "Enable libeconf support.", default = false, type = "boolean"})

    add_deps("meson", "ninja")
    on_load(function(package)
        if package:config("audit") then
            package:add("deps", "audit")
        end
        if package:config("econf") then
            package:add("deps", "libeconf")
        end
    end)

    on_install("linux", function (package)
        local configs = {
            '-Ddocs=disabled',
            '-Dxtests=false',
            '-Dexamples=false'
        }

        table.insert(configs, "-Di18n=" .. (package:config("i18n") and "enabled" or "disabled"))
        table.insert(configs, "-Daudit=" .. (package:config("audit") and "enabled" or "disabled"))
        table.insert(configs, "-Deconf=" .. (package:config("econf") and "enabled" or "disabled"))

        io.replace("meson.build", "subdir('po')", "", {plain = true})
        io.replace("meson.build", "subdir('tests')", "", {plain = true})
        io.replace("meson.build", "subdir('modules')", "", {plain = true})
        io.replace("meson.build", "subdir('conf' / 'pam_conv1')", "", {plain = true})

        local packagedeps = {}
        if package:config("audit") then
            table.insert(packagedeps, "libcap-ng")
        end

        import("package.tools.meson").install(package, configs, {packagedeps = packagedeps})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pamc_start", {includes = "security/pam_client.h"}))
    end)
