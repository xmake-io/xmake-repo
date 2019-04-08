package("util-linux")

    set_homepage("https://github.com/karelzak/util-linux")
    set_description("Collection of Linux utilities.")

    set_urls("https://www.kernel.org/pub/linux/utils/util-linux/v2.32/util-linux-$(version).tar.xz")
    add_versions("2.32.1", "86e6707a379c7ff5489c218cfaf1e3464b0b95acf7817db0bc5f179e356a67b2")

    if not is_plat("macosx") then
        add_deps("ncurses", "zlib")
    end

    add_configs("ipcs",               { description = "Enable ipcs.", default = false, type = "boolean"})
    add_configs("ipcrm",              { description = "Enable ipcrm.", default = false, type = "boolean"})
    add_configs("wall",               { description = "Enable wall.", default = false, type = "boolean"})
    add_configs("libuuid",            { description = "Enable libuuid.", default = false, type = "boolean"})
    add_configs("libsmartcols",       { description = "Enable libsmartcols.", default = false, type = "boolean"})
    add_configs("use-tty-group",      { description = "Enable use-tty-group.", default = false, type = "boolean"})
    add_configs("kill",               { description = "Enable kill.", default = false, type = "boolean"})
    add_configs("cal",                { description = "Enable cal.", default = false, type = "boolean"})
    add_configs("systemd",            { description = "Enable systemd.", default = false, type = "boolean"})
    add_configs("chfn-chsh",          { description = "Enable chfn-chsh.", default = false, type = "boolean"})
    add_configs("login",              { description = "Enable login.", default = false, type = "boolean"})
    add_configs("su",                 { description = "Enable su.", default = false, type = "boolean"})
    add_configs("runuser",            { description = "Enable runuser.", default = false, type = "boolean"})
    add_configs("makeinstall-chown",  { description = "Enable makeinstall-chown.", default = false, type = "boolean"})
    add_configs("makeinstall-setuid", { description = "Enable makeinstall-setuid.", default = false, type = "boolean"})

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_install("macosx", "linux", function (package)
        local configs = {"--disable-dependency-tracking", "--disable-silent-rules", "--without-python"}
        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                if enabled then
                    table.insert(configs, "--enable-" .. name)
                else
                    table.insert(configs, "--disable-" .. name)
                end
            end
        end
        import("package.tools.autoconf").install(package, configs)
    end)

