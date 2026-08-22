package("libtool")
    set_homepage("https://www.gnu.org/software/libtool/")
    set_description("A generic library support script.")
    set_kind("binary")
    add_urls("http://ftpmirror.gnu.org/libtool/libtool-$(version).tar.gz",
             "https://mirrors.ustc.edu.cn/gnu/libtool/libtool-$(version).tar.gz",
             "git://git.savannah.gnu.org/libtool.git")
    add_urls("https://distfiles.gentoo.org/distfiles/78/libtool-$(version).tar.xz", {alias = "temp"})

    add_versions("2.4.6", "e3bd4d5d3d025a36c21dd6af7ea818a2afcd4dfc1ea5a17b39d7854bcd0c06e3")
    add_versions("2.4.5", "509cb49c7de14ce7eaf88993cf09fd4071882699dfd874c2e95b31ab107d6987")
    add_versions("2.4.7", "04e96c2404ea70c590c546eba4202a4e12722c640016c12b9b2f1ce3d481e9a8")
    add_versions("2.5.4", "da8ebb2ce4dcf46b90098daf962cffa68f4b4f62ea60f798d0ef12929ede6adf")
    add_versions("temp:2.6.0", "69e6d28ae880fda08e0dc080ef2e38077ea2765a0d84e1afcfcfe1e605c911ac")

    on_load(function (package)
        if package:is_library() then
            package:addenv("PATH", "bin")
        end
    end)

    if is_plat("linux") then
        add_syslinks("dl")
    end

    if is_host("linux") then
        add_extsources("apt::libtool", "pacman::libtool")
    elseif is_host("macosx") then
        add_extsources("brew::libtool")
    end

    add_deps("autoconf")

    on_install("@macosx", "@linux", "@bsd", function (package)
        local configs = {"--disable-dependency-tracking", "--enable-ltdl-install"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        import("package.tools.autoconf").install(package, configs)
        if package:is_plat("macosx") then
            local bindir = package:installdir("bin")
            os.ln(path.join(bindir, "libtoolize"), path.join(bindir, "glibtoolize"))
        end
    end)

    on_test(function (package)
        if not package:is_binary() then
            assert(package:has_cfuncs("lt_dlopen", {includes = "ltdl.h"}))
        else
            os.vrun("libtool --version")
        end
    end)
