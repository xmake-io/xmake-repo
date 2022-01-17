package("libxcb")

    set_homepage("https://www.x.org/")
    set_description("X.Org: Interface to the X Window System protocol")

    set_urls("https://xcb.freedesktop.org/dist/libxcb-$(version).tar.gz")
    add_versions("1.13.1", "f09a76971437780a602303170fd51b5f7474051722bc39d566a272d2c4bde1b5")
    add_versions("1.14", "2c7fcddd1da34d9b238c9caeda20d3bd7486456fc50b3cc6567185dbd5b0ad02")

    add_configs("composite", {description = "Enable composite submodule (default is true).", default = true, type = "boolean"})
    add_configs("damage", {description = "Enable damage submodule (default is true).", default = true, type = "boolean"})
    add_configs("dpms", {description = "Enable dpms submodule (default is true).", default = true, type = "boolean"})
    add_configs("dri2", {description = "Enable dri2 submodule (default is true).", default = true, type = "boolean"})
    add_configs("dri3", {description = "Enable dri3 submodule (default is true).", default = true, type = "boolean"})
    add_configs("present", {description = "Enable present submodule (default is true).", default = true, type = "boolean"})
    add_configs("glx", {description = "Enable glx submodule (default is true).", default = true, type = "boolean"})
    add_configs("randr", {description = "Enable randr submodule (default is true).", default = true, type = "boolean"})
    add_configs("record", {description = "Enable record submodule (default is true).", default = true, type = "boolean"})
    add_configs("render", {description = "Enable render submodule (default is true).", default = true, type = "boolean"})
    add_configs("resource", {description = "Enable resource submodule (default is true).", default = true, type = "boolean"})
    add_configs("screensaver", {description = "Enable screensaver submodule (default is true).", default = true, type = "boolean"})
    add_configs("shape", {description = "Enable shape submodule (default is true).", default = true, type = "boolean"})
    add_configs("shm", {description = "Enable shm submodule (default is true).", default = true, type = "boolean"})
    add_configs("sync", {description = "Enable sync submodule (default is true).", default = true, type = "boolean"})
    add_configs("xevie", {description = "Enable xevie submodule (default is true).", default = false, type = "boolean"})
    add_configs("xfree86dri", {description = "Enable xfree86-dri submodule (default is true).", default = true, type = "boolean"})
    add_configs("xfixes", {description = "Enable xfixes submodule (default is true).", default = true, type = "boolean"})
    add_configs("xinerama", {description = "Enable xinerama submodule (default is true).", default = true, type = "boolean"})
    add_configs("xinput", {description = "Enable xinput submodule (default is true).", default = true, type = "boolean"})
    add_configs("xkb", {description = "Enable xkb submodule (default is true).", default = true, type = "boolean"})
    add_configs("xprint", {description = "Enable xprint submodule (default is true).", default = false, type = "boolean"})
    add_configs("selinux", {description = "Enable selinux submodule (default is true).", default = false, type = "boolean"})
    add_configs("xtest", {description = "Enable xtest submodule (default is true).", default = true, type = "boolean"})
    add_configs("xv", {description = "Enable xv submodule (default is true).", default = true, type = "boolean"})
    add_configs("xvmc", {description = "Enable xvmc submodule (default is true).", default = true, type = "boolean"})
    add_configs("ge", {description = "Enable ge submodule (default is false).", default = true, type = "boolean"})

    if is_plat("linux") then
        add_extsources("apt::libxcb1-dev", "pacman::libxcb")
    end

    if is_plat("macosx", "linux") then
        add_deps("pkg-config", "python 3.x", {kind = "binary"})
        add_deps("xcb-proto", "libpthread-stubs", "libxau", "libxdmcp")
    end

    on_load("linux", function(package)
        if package:config("composite") then
            package:add("extsources", "apt::libxcb-composite0-dev")
        end

        if package:config("damage") then
            package:add("extsources", "apt::libxcb-damage0-dev")
        end

        if package:config("dpms") then
            package:add("extsources", "apt::libxcb-dpms0-dev")
        end

        if package:config("dri2") then
            package:add("extsources", "apt::libxcb-dri2-0-dev")
        end

        if package:config("dri3") then
            package:add("extsources", "apt::libxcb-dri3-dev")
        end

        if package:config("present") then
            package:add("extsources", "apt::libxcb-present-dev")
        end

        if package:config("glx") then
            package:add("extsources", "apt::libxcb-glx0-dev")
        end

        if package:config("randr") then
            package:add("extsources", "apt::libxcb-randr0-dev")
        end

        if package:config("record") then
            package:add("extsources", "apt::libxcb-record0-dev")
        end

        if package:config("render") then
            package:add("extsources", "apt::libxcb-render0-dev")
        end

        if package:config("resource") then
            package:add("extsources", "apt::libxcb-xrm-dev")
        end

        if package:config("screensaver") then
            package:add("extsources", "apt::libxcb-screensaver-dev")
        end

        if package:config("shape") then
            package:add("extsources", "apt::libxcb-shape0-dev")
        end

        if package:config("shm") then
            package:add("extsources", "apt::libxcb-shm0-dev")
        end

        if package:config("sync") then
            package:add("extsources", "apt::libxcb-sync0-dev")
        end

        if package:config("xevie") then
            package:add("extsources", "apt::libxcb-xevie0-dev")
        end

        if package:config("xfree86dri") then
            package:add("extsources", "apt::libxcb-xfreedri0-dev")
        end

        if package:config("xfixes") then
            package:add("extsources", "apt::libxcb-xfixes0-dev")
        end

        if package:config("xinerama") then
            package:add("extsources", "apt::libxcb-xinerama0-dev")
        end

        if package:config("xinput") then
            package:add("extsources", "apt::libxcb-xinput-dev")
        end

        if package:config("xkb") then
            package:add("extsources", "apt::libxcb-xkb-dev")
        end

        if package:config("xprint") then
            package:add("extsources", "apt::libxcb-xprint0-dev")
        end

        if package:config("xtest") then
            package:add("extsources", "apt::libxcb-xtest0-dev")
        end

        if package:config("xvmc") then
            package:add("extsources", "apt::libxcb-xv0-dev")
        end

        if package:config("xv") then
            package:add("extsources", "apt::libxcb-xvmc0-dev")
        end
    end)

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--enable-composite=" .. format("%s", package:config("composite")),
                         "--enable-damage=" .. format("%s", package:config("damage")),
                         "--enable-dpms=" .. format("%s", package:config("dpms")),
                         "--enable-dri2=" .. format("%s", package:config("dri2")),
                         "--enable-dri3=" .. format("%s", package:config("dri3")),
                         "--enable-present=" .. format("%s", package:config("present")),
                         "--enable-glx=" .. format("%s", package:config("glx")),
                         "--enable-randr=" .. format("%s", package:config("randr")),
                         "--enable-record=" .. format("%s", package:config("record")),
                         "--enable-render=" .. format("%s", package:config("render")),
                         "--enable-resource=" .. format("%s", package:config("resource")),
                         "--enable-screensaver=" .. format("%s", package:config("screensaver")),
                         "--enable-shape=" .. format("%s", package:config("shape")),
                         "--enable-shm=" .. format("%s", package:config("shm")),
                         "--enable-sync=" .. format("%s", package:config("sync")),
                         "--enable-xevie=" .. format("%s", package:config("xevie")),
                         "--enable-xfree86-dri=" .. format("%s", package:config("xfree86dri")),
                         "--enable-xfixes=" .. format("%s", package:config("xfixes")),
                         "--enable-xinerama=" .. format("%s", package:config("xinerama")),
                         "--enable-xinput=" .. format("%s", package:config("xinput")),
                         "--enable-xkb=" .. format("%s", package:config("xkb")),
                         "--enable-xprint=" .. format("%s", package:config("xprint")),
                         "--enable-selinux=" .. format("%s", package:config("selinux")),
                         "--enable-xtest=" .. format("%s", package:config("xtest")),
                         "--enable-xv=" .. format("%s", package:config("xv")),
                         "--enable-xvmc=" .. format("%s", package:config("xvmc")),
                         "--enable-ge=" .. format("%s", package:config("ge")),
                         "--disable-dependency-tracking",
                         "--disable-silent-rules",
                         "--enable-devel-docs=no",
                         "--with-doxygen=no"}
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("xcb_connect", {includes = "xcb/xcb.h"}))
    end)
