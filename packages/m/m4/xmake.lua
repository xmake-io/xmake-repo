package("m4")

    set_kind("binary")
    set_homepage("https://www.gnu.org/software/m4")
    set_description("Macro processing language")

    add_urls("https://ftp.gnu.org/gnu/m4/m4-$(version).tar.xz",
             "https://ftpmirror.gnu.org/m4/m4-$(version).tar.xz")
    add_versions("1.4.18", "f2c1e86ca0a404ff281631bdc8377638992744b175afb806e25871a24a934e07")

    if is_host("macosx") then
        -- fix crash from usage of %n in dynamic format strings on High Sierra
        -- patch credit to Jeremy Huddleston Sequoia <jeremyhu@apple.com>
        add_patches("1.4.18", path.join(os.scriptdir(), "patches", "1.4.18", "secure_snprintf.patch"), "c0a408fbffb7255fcc75e26bd8edab116fc81d216bfd18b473668b7739a4158e")
    end

    on_install("@macosx", "@linux", function (package)
        import("package.tools.autoconf").install(package, {"--disable-dependency-tracking"})
    end)

    if is_subhost("msys") then
        on_install("@windows", function (package)
            import("package.tools.autoconf").install(package, {"--disable-dependency-tracking"})
        end)
    end

    on_test(function (package)
        os.vrun("m4 --version")
    end)
