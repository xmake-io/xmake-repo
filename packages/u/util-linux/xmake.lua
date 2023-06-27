package("util-linux")

    set_homepage("https://github.com/util-linux/util-linux")
    set_description("Collection of Linux utilities.")
    set_license("GPL-2.0")

    set_urls("https://www.kernel.org/pub/linux/utils/util-linux/v$(version).tar.xz", {version = function (version)
        return format("%s.%s/util-linux-%s", version:major(), version:minor(), version)
    end})
    add_versions("2.32.1", "86e6707a379c7ff5489c218cfaf1e3464b0b95acf7817db0bc5f179e356a67b2")
    add_versions("2.36.2", "f7516ba9d8689343594356f0e5e1a5f0da34adfbc89023437735872bb5024c5f")
    add_versions("2.39",   "32b30a336cda903182ed61feb3e9b908b762a5e66fe14e43efb88d37162075cb")

    add_patches("2.36.2", path.join(os.scriptdir(), "patches", "2.36.2", "includes.patch"), "7274762cac2810b5f0d17ecb5ac69c7069e7ff2b880df663b7072628df0867f3")

    if is_plat("macosx") then
        add_extsources("brew::util-linux")
    elseif is_plat("linux") then
        add_extsources("apt::util-linux", "pacman::util-linux")
        add_deps("ncurses", "zlib")
    end

    add_configs("ipcs",               {description = "Enable ipcs.", default = false, type = "boolean"})
    add_configs("ipcrm",              {description = "Enable ipcrm.", default = false, type = "boolean"})
    add_configs("wall",               {description = "Enable wall.", default = false, type = "boolean"})
    add_configs("libuuid",            {description = "Enable libuuid.", default = false, type = "boolean"})
    add_configs("libblkid",           {description = "Enable libblkid.", default = false, type = "boolean"})
    add_configs("libmount",           {description = "Enable libmount.", default = false, type = "boolean"})
    add_configs("libsmartcols",       {description = "Enable libsmartcols.", default = false, type = "boolean"})
    add_configs("libfdisk",           {description = "Enable libfdisk.", default = false, type = "boolean"})
    add_configs("use-tty-group",      {description = "Enable use-tty-group.", default = false, type = "boolean"})
    add_configs("kill",               {description = "Enable kill.", default = false, type = "boolean"})
    add_configs("cal",                {description = "Enable cal.", default = false, type = "boolean"})
    add_configs("systemd",            {description = "Enable systemd.", default = false, type = "boolean"})
    add_configs("chfn-chsh",          {description = "Enable chfn-chsh.", default = false, type = "boolean"})
    add_configs("login",              {description = "Enable login.", default = false, type = "boolean"})
    add_configs("su",                 {description = "Enable su.", default = false, type = "boolean"})
    add_configs("mount",              {description = "Enable mount.", default = false, type = "boolean"})
    add_configs("runuser",            {description = "Enable runuser.", default = false, type = "boolean"})
    add_configs("makeinstall-chown",  {description = "Enable makeinstall-chown.", default = false, type = "boolean"})
    add_configs("makeinstall-setuid", {description = "Enable makeinstall-setuid.", default = false, type = "boolean"})

    on_load(function (package)
        package:addenv("PATH", "bin")
        package:addenv("PATH", "sbin")
    end)

    on_install("macosx", "linux", function (package)
        local configs = {"--disable-dependency-tracking",
                         "--disable-silent-rules",
                         "--without-python",
                         "--without-systemd",
                         "--with-bashcompletiondir=" .. path.join(package:installdir("share"), "bash-completion")}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
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
