package("libverto")

    set_homepage("https://github.com/latchset/libverto")
    set_description("An async event loop abstraction library")
    set_license("MIT")

    add_urls("https://github.com/latchset/libverto/releases/download/$(version)/libverto-$(version).tar.gz")
    add_versions("0.3.2", "8d1756fd704f147549f606cd987050fb94b0b1ff621ea6aa4d6bf0b74450468a")

    local cdeps = {"glib", "libev", "libevent"}
    for _, cdep in ipairs(cdeps) do
        add_configs(cdep, {description = "Enable " .. cdep .. " support.", default = false, type = "boolean"})
    end
    on_load("macosx", "linux", function (package)
        for _, cdep in ipairs(cdeps) do
            if package:config(cdep) then
                package:add("deps", cdep)
            end
        end
    end)

    on_install("macosx", "linux", function (package)
        local configs = {"--disable-dependency-tracking"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        for _, cdep in ipairs(cdeps) do
            table.insert(configs, "--with-" .. cdep .. "=" .. (package:config(cdep) and "yes" or "no"))
        end
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("verto_get_supported_types", {includes = "verto-module.h"}))
    end)
