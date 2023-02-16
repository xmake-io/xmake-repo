package("swig")

    set_kind("binary")
    set_homepage("http://swig.org/")
    set_description("SWIG is a software development tool that connects programs written in C and C++ with a variety of high-level programming languages.")
    set_license("GPL-3.0")

    if is_host("windows") then
        add_urls("https://sourceforge.net/projects/swig/files/swigwin/swigwin-$(version)/swigwin-$(version).zip")
        add_versions("4.0.2", "daadb32f19fe818cb9b0015243233fc81584844c11a48436385e87c050346559")
        add_versions("4.1.1", "2ec3107e24606db535d77ef3dbf246dc6eccbf1d5c868dce365d7f7fb19a1a51")
    else
        add_urls("https://sourceforge.net/projects/swig/files/swig/swig-$(version)/swig-$(version).tar.gz")
        add_versions("4.0.2", "d53be9730d8d58a16bf0cbd1f8ac0c0c3e1090573168bfa151b01eb47fa906fc")
        add_versions("4.1.1", "2af08aced8fcd65cdb5cc62426768914bedc735b1c250325203716f78e39ac9b")
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
