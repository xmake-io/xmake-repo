package("icu4c")

    set_homepage("http://site.icu-project.org/")
    set_description("C/C++ libraries for Unicode and globalization.")

    add_urls("https://github.com/unicode-org/icu/releases/download/release-$(version)-src.tgz", {version = function (version)
            return (version:gsub("%.", "-")) .. "/icu4c-" .. (version:gsub("%.", "_"))
        end})
    add_versions("68.2", "c79193dee3907a2199b8296a93b52c5cb74332c26f3d167269487680d479d625")
    add_versions("68.1", "a9f2e3d8b4434b8e53878b4308bd1e6ee51c9c7042e2b1a376abefb6fbb29f2d")
    add_versions("64.2", "627d5d8478e6d96fc8c90fed4851239079a561a6a8b9e48b0892f24e82d31d6c")

    add_links("icuuc", "icutu", "icui18n", "icuio", "icudata")
    if is_plat("linux") then
        add_syslinks("dl")
    end
    if is_plat("windows") then
        add_deps("python 3.x", {kind = "binary"})
    end

    on_install("windows", function (package)
        import("package.tools.msbuild")

        -- set configs
        local configs = {path.join("source", "allinone", "allinone.sln"), "/p:SkipUWP=True", "/p:_IsNativeEnvironment=true"}
        table.insert(configs, "/p:Configuration=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "/p:Platform=" .. (package:is_arch("x64") and "x64" or "Win32"))

        -- set envs
        local envs = msbuild.buildenvs(package)
        envs.PATH = package:dep("python"):installdir("bin") .. path.envsep() .. envs.PATH

        -- build
        msbuild.build(package, configs, {envs = envs})
        os.cp("include", package:installdir())
        os.cp("bin*/*", package:installdir("bin"))
        os.cp("lib*/*", package:installdir("lib"))
        package:addenv("PATH", "bin")
    end)

    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf")

        os.cd("source")
        local configs = {"--disable-samples", "--disable-tests"}
        if package:debug() then
            table.insert(configs, "--enable-debug")
            table.insert(configs, "--disable-release")
        end
        if package:config("shared") then
            table.insert(configs, "--enable-shared")
            table.insert(configs, "--disable-static")
        else
            table.insert(configs, "--disable-shared")
            table.insert(configs, "--enable-static")
        end

        local envs = {}
        if package:is_plat("linux") and not package:config("shared") then
            envs = autoconf.buildenvs(package, {cxflags = "-fPIC"})
        else
            envs = autoconf.buildenvs(package)
        end
        autoconf.install(package, configs, {envs = envs})
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ucnv_convert", {includes = "unicode/ucnv.h"}))
    end)
