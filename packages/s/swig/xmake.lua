package("swig")

    set_kind("binary")
    set_homepage("http://swig.org/")
    set_description("SWIG is a software development tool that connects programs written in C and C++ with a variety of high-level programming languages.")
    set_license("GPL-3.0")

    if is_host("windows") then
        add_urls("https://sourceforge.net/projects/swig/files/swigwin/swigwin-$(version)/swigwin-$(version).zip")
        add_versions("4.0.2", "daadb32f19fe818cb9b0015243233fc81584844c11a48436385e87c050346559")
    else
        add_urls("https://sourceforge.net/projects/swig/files/swig/swig-$(version)/swig-$(version).tar.gz")
        add_versions("4.0.2", "d53be9730d8d58a16bf0cbd1f8ac0c0c3e1090573168bfa151b01eb47fa906fc")
    end

    if is_host("macosx", "linux") then
        add_deps("pcre", {host = true})
    end

    on_install("@windows", function (package)
        os.cp("*|Doc|Examples", package:installdir())
        package:addenv("PATH", ".")
    end)

    on_install("@macosx", "@linux", function (package)
        local configs = {}
        local pcre = package:dep("pcre")
        if pcre and not pcre:is_system() then
            table.insert(configs, "--with-pcre-prefix=" .. pcre:installdir())
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        os.vrun("swig -version")
    end)
