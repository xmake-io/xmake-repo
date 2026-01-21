local components = {
    composite       = {apt_package = "apt::libxcb-composite0-dev", default_value = true},
    damage          = {apt_package = "apt::libxcb-damage0-dev" , default_value = true},
    dpms            = {apt_package = "apt::libxcb-dpms0-dev" , default_value = true},
    dri2            = {apt_package = "apt::libxcb-dri2-0-dev" , default_value = true},
    dri3            = {apt_package = "apt::libxcb-dri3-dev" , default_value = true},
    present         = {apt_package = "apt::libxcb-present-dev" , default_value = true},
    glx             = {apt_package = "apt::libxcb-glx0-dev" , default_value = true},
    randr           = {apt_package = "apt::libxcb-randr0-dev" , default_value = true},
    record          = {apt_package = "apt::libxcb-record0-dev" , default_value = true},
    render          = {apt_package = "apt::libxcb-render0-dev" , default_value = true},
    resource        = {apt_package = "apt::libxcb-xrm-dev" , default_value = true},
    screensaver     = {apt_package = "apt::libxcb-screensaver-dev" , default_value = true},
    shape           = {apt_package = "apt::libxcb-shape0-dev" , default_value = true},
    shm             = {apt_package = "apt::libxcb-shm0-dev" , default_value = true},
    sync            = {apt_package = "apt::libxcb-sync0-dev" , default_value = true},
    xevie           = {apt_package = "apt::libxcb-xevie0-dev" , default_value = true},
    ["xfree86-dri"] = {apt_package = "apt::libxcb-xfreedri0-dev" , default_value = true},
    xfixes          = {apt_package = "apt::libxcb-xfixes0-dev" , default_value = true},
    xinerama        = {apt_package = "apt::libxcb-xinerama0-dev" , default_value = true},
    xinput          = {apt_package = "apt::libxcb-xinput-dev" , default_value = true},
    xkb             = {apt_package = "apt::libxcb-xkb-dev" , default_value = true},
    xprint          = {apt_package = "apt::libxcb-xprint0-dev" , default_value = false},
    selinux         = {default_value = false},
    xtest           = {apt_package = "apt::libxcb-xtest0-dev" , default_value = true},
    xv              = {apt_package = "apt::libxcb-xv0-dev" , default_value = true},
    xvmc            = {apt_package = "apt::libxcb-xvmc0-dev" , default_value = true},
    ge              = {default_value = true}
}

package("libxcb")
    set_homepage("https://www.x.org/")
    set_description("X.Org: Interface to the X Window System protocol")

    add_urls("https://xcb.freedesktop.org/dist/libxcb-$(version).tar.gz",
             "https://www.x.org/archive/individual/lib/libxcb-$(version).tar.gz")
    add_versions("1.13.1", "f09a76971437780a602303170fd51b5f7474051722bc39d566a272d2c4bde1b5")
    add_versions("1.14", "2c7fcddd1da34d9b238c9caeda20d3bd7486456fc50b3cc6567185dbd5b0ad02")
    add_versions("1.16", "bc0f75f84b28e6496a19a1d094d7e47def861a50cb7cce5b23b62eecdc2a4479")
    add_versions("1.17.0", "2c69287424c9e2128cb47ffe92171e10417041ec2963bceafb65cb3fcf8f0b85")

    for name, opt in pairs(components) do
        add_configs(name, {description = format("Enable %s submodule (default is %s).", name, opt.default_value), default = opt.default_value})
    end

    if is_plat("linux") then
        add_extsources("apt::libxcb1-dev", "pacman::libxcb")
    end

    if is_plat("macosx", "linux", "bsd", "cross") then
        add_deps("pkg-config", "python 3.x", {kind = "binary"})
        add_deps("xcb-proto", "libpthread-stubs")
    end

    on_load(function(package)
        package:add("deps", "libxau", "libxdmcp", { configs = { shared = package:config("shared") } })
        if package:is_plat("linux") then
            for name, opt in pairs(components) do
                if opt.apt_package and package:config(name) then
                    package:add("extsources", opt.apt_package)
                end
            end
        end
    end)

    on_install("macosx", "linux", "bsd", "cross", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-dependency-tracking",
                         "--disable-silent-rules",
                         "--enable-devel-docs=no",
                         "--with-doxygen=no",
                         "PYTHON=python3"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:is_plat("linux") and package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        for name, opt in pairs(components) do
            table.insert(configs, format("--enable-%s=%s", name, package:config(name) and "yes" or "no"))
        end
        if package:is_plat("macosx") and package:is_cross() then
            import("package.tools.autoconf").install(package, configs, {cflags = "-arch " .. package:arch(), shflags = "-arch " .. package:arch()})
        else
            local c_link_args
            -- fix undefined reference to XauGetBestAuthByAddr on linux
            if package:config("x11") then
                for _, dep in ipairs(package:orderdeps()) do
                    local fetchinfo = dep:fetch()
                    if fetchinfo then
                        for _, linkdir in ipairs(fetchinfo.linkdirs) do
                            c_link_args = c_link_args .. " -L" .. linkdir
                        end
                        for _, link in ipairs(fetchinfo.links) do
                            c_link_args = c_link_args .. " -l" .. link
                        end
                    end
                end
            end
            import("package.tools.autoconf").install(package, configs, {ldflags = c_link_args, shflags = c_link_args})
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("xcb_connect", {includes = "xcb/xcb.h"}))
    end)
