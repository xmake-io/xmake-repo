package("icu4c")

    set_homepage("http://site.icu-project.org/")
    set_description("C/C++ libraries for Unicode and globalization.")

    add_urls("https://github.com/unicode-org/icu/releases/download/release-$(version)-src.tgz", {version = function (version)
            return (version:gsub("%.", "-")) .. "/icu4c-" .. (version:gsub("%.", "_"))
        end})
    add_versions("73.1", "a457431de164b4aa7eca00ed134d00dfbf88a77c6986a10ae7774fc076bb8c45")
    add_versions("72.1", "a2d2d38217092a7ed56635e34467f92f976b370e20182ad325edea6681a71d68")
    add_versions("71.1", "67a7e6e51f61faf1306b6935333e13b2c48abd8da6d2f46ce6adca24b1e21ebf")
    add_versions("70.1", "8d205428c17bf13bb535300669ed28b338a157b1c01ae66d31d0d3e2d47c3fd5")
    add_versions("69.1", "4cba7b7acd1d3c42c44bb0c14be6637098c7faf2b330ce876bc5f3b915d09745")
    add_versions("68.2", "c79193dee3907a2199b8296a93b52c5cb74332c26f3d167269487680d479d625")
    add_versions("68.1", "a9f2e3d8b4434b8e53878b4308bd1e6ee51c9c7042e2b1a376abefb6fbb29f2d")
    add_versions("64.2", "627d5d8478e6d96fc8c90fed4851239079a561a6a8b9e48b0892f24e82d31d6c")

    add_patches("69.1", path.join(os.scriptdir(), "patches", "69.1", "replace-py-3.patch"), "ae27a55b0e79a8420024d6d349a7bae850e1dd403a8e1131e711c405ddb099b9")
    add_patches("70.1", path.join(os.scriptdir(), "patches", "70.1", "replace-py-3.patch"), "6469739da001721122b62af513370ed62901caf43af127de3f27ea2128830e35")
    if is_plat("mingw") then
        add_patches("72.1", path.join(os.scriptdir(), "patches", "72.1", "mingw.patch"), "9ddbe7f691224ccf69f8c0218f788f0a39ab8f1375cc9aad2cc92664ffcf46a5")
        add_patches("73.1", path.join(os.scriptdir(), "patches", "72.1", "mingw.patch"), "9ddbe7f691224ccf69f8c0218f788f0a39ab8f1375cc9aad2cc92664ffcf46a5")
    end

    add_links("icutu", "icuio")
    if is_plat("mingw", "windows") then
        add_links("icuin", "icuuc", "icudt")
    else
        add_links("icui18n", "icuuc", "icudata")
    end

    if is_plat("linux") then
        add_syslinks("dl")
    end
    if is_plat("windows") then
        add_deps("python 3.x", {kind = "binary"})
    end

    on_install("windows", function (package)
        local configs = {path.join("source", "allinone", "allinone.sln"), "/p:SkipUWP=True", "/p:_IsNativeEnvironment=true"}
        table.insert(configs, "/p:Configuration=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "/p:Platform=" .. (package:is_arch("x64") and "x64" or "Win32"))
        import("package.tools.msbuild").build(package, configs)
        os.cp("include", package:installdir())
        os.cp("bin*/*", package:installdir("bin"))
        os.cp("lib*/*", package:installdir("lib"))
        package:addenv("PATH", "bin")
    end)

    on_install("macosx", "linux", "mingw@msys", function (package)
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
        if package:is_plat("mingw") then
            table.insert(configs, "--with-data-packaging=dll")
        end

        local envs = {}
        if package:is_plat("linux") and package:config("pic") ~= false then
            envs = autoconf.buildenvs(package, {cxflags = "-fPIC"})
        else
            envs = autoconf.buildenvs(package)
        end
        -- suppress ar errors when passing --toolchain=clang
        envs.ARFLAGS = nil
        autoconf.install(package, configs, {envs = envs})
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ucnv_convert", {includes = "unicode/ucnv.h"}))
    end)
