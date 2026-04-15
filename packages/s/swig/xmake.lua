package("swig")

    set_kind("binary")
    set_homepage("http://swig.org/")
    set_description("SWIG is a software development tool that connects programs written in C and C++ with a variety of high-level programming languages.")
    set_license("GPL-3.0")

    if is_host("windows") then
        add_urls("https://sourceforge.net/projects/swig/files/swigwin/swigwin-$(version)/swigwin-$(version).zip")
        add_versions("4.0.2", "daadb32f19fe818cb9b0015243233fc81584844c11a48436385e87c050346559")
        add_versions("4.1.1", "2ec3107e24606db535d77ef3dbf246dc6eccbf1d5c868dce365d7f7fb19a1a51")
        add_versions("4.2.1", "2ca18cfb4aa78a59a979c3f5c47ea9f19b6ac0eb7714ca5d1df8c01d0029e3a9")
        add_versions("4.3.1", "7ea5197c557af20b2f7780ffcfe803bbe0e2009f5846874112aea37e5f693417")
        add_versions("4.4.1", "ce01474c81120eab381491d8d45cbcce4768fd1e5c23ffc7654b522702769598")
    else
        add_urls("https://sourceforge.net/projects/swig/files/swig/swig-$(version)/swig-$(version).tar.gz")
        add_versions("4.0.2", "d53be9730d8d58a16bf0cbd1f8ac0c0c3e1090573168bfa151b01eb47fa906fc")
        add_versions("4.1.1", "2af08aced8fcd65cdb5cc62426768914bedc735b1c250325203716f78e39ac9b")
        add_versions("4.2.1", "fa045354e2d048b2cddc69579e4256245d4676894858fcf0bab2290ecf59b7d8")
        add_versions("4.3.1", "44fc829f70f1e17d635a2b4d69acab38896699ecc24aa023e516e0eabbec61b8")
        add_versions("4.4.1", "40162a706c56f7592d08fd52ef5511cb7ac191f3593cf07306a0a554c6281fcf")
    end

    on_load("@macosx", "@linux", function (package)
        if package:version():ge("4.1") then
            package:add("deps", "pcre2", {host = true})
        else
            package:add("deps", "pcre", {host = true})
        end
    end)

    on_fetch(function (package, opt)
        if opt.system then
            return package:find_tool("swig")
        end
    end)

    on_install("@windows", function (package)
        os.cp("*|Doc|Examples", package:installdir())
        package:addenv("PATH", ".")
    end)

    on_install("@macosx", "@linux", function (package)
        local configs = {}
        if package:version():ge("4.1") then
            local pcre2 = package:dep("pcre2")
            if pcre2 and not pcre2:is_system() then
                table.insert(configs, "--with-pcre2-prefix=" .. pcre2:installdir())
            end
        else
            local pcre = package:dep("pcre")
            if pcre and not pcre:is_system() then
                table.insert(configs, "--with-pcre-prefix=" .. pcre:installdir())
            end
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        os.vrun("swig -version")
    end)
