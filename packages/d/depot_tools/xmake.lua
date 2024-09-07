package("depot_tools")
    set_kind("binary")
    set_homepage("https://chromium.googlesource.com/chromium/tools/depot_tools")
    set_description("Tools for working with Chromium development")

    add_urls("https://github.com/xmake-mirror/depot_tools.git",
             "https://chromium.googlesource.com/chromium/tools/depot_tools.git")
    add_versions("2022.2.1", "8a6d00f116d6de9d5c4e92acb519fd0859c6449a")
    add_versions("2024.2.29", "50de666ba40a4808daf9791fece3d8a43228a1de")
    add_versions("2024.7.4", "452fe3be37f78fbecefa1b4b0d359531bcd70d0d")

    -- we use external ninja instead of depot_tools/ninja which eating ram until VM exhaustion (16GB)
    add_deps("ninja", {private = true, system = false})

    on_load(function (package)
        package:addenv("PATH", ".")
        package:addenv("PATH", "python-bin")
        package:addenv("DEPOT_TOOLS_UPDATE", "0")
        package:addenv("DEPOT_TOOLS_METRICS", "0")
        package:addenv("DEPOT_TOOLS_WIN_TOOLCHAIN", "0")
    end)

    on_install("linux", "macosx", "windows", function (package)
        import("core.base.global")
        local sourcedir = os.curdir()
        os.cp("*", package:installdir())
        os.cd(package:installdir())
        -- maybe we need set proxy, e.g. `xmake g --proxy=http://127.0.0.1:xxxx`
        -- @note we must use http proxy instead of socks5 proxy
        local envs = {}
        local proxy = global.get("proxy")
        if proxy then
            envs.HTTP_PROXY = proxy
            envs.HTTPS_PROXY = proxy
            envs.ALL_PROXY = proxy
        end
        envs.PATH = table.join(sourcedir, path.splitenv(os.getenv("PATH")))
        -- skip to check and update obsolete URL
        io.replace("./update_depot_tools",
            'CANONICAL_GIT_URL="https://chromium.googlesource.com/chromium/tools/depot_tools.git"',
            'CANONICAL_GIT_URL="https://github.com/xmake-mirror/depot_tools.git"', {plain = true})
        io.replace("./update_depot_tools", 'remote_url=$(eval "$GIT" config --get remote.origin.url)',
            'remote_url="https://github.com/xmake-mirror/depot_tools.git"', {plain = true})
        os.vrunv("git", {"config", "user.email", "you@example.com"})
        os.vrunv("git", {"config", "user.name", "me"})
        os.vrunv("git", {"commit", "-a", "-m", "..."})
        -- we need fetch some files when running gclient for the first time
        if is_host("windows") then
            os.vrunv("gclient.bat", {"--verbose"}, {envs = envs})
        else
            os.vrunv("./gclient", {"--verbose"}, {shell = true, envs = envs})
        end
        local ninja = path.join(package:dep("ninja"):installdir("bin"), "ninja" .. (is_host("windows") and ".exe" or ""))
        if ninja and os.isfile(ninja) then
            os.cp(ninja, package:installdir())
        end
    end)

    on_test(function (package)
        import("core.base.global")
        os.vrun("python3 --version")
        os.vrun("ninja --version")
        local envs = {}
        local proxy = global.get("proxy")
        if proxy then
            envs.HTTP_PROXY = proxy
            envs.HTTPS_PROXY = proxy
            envs.ALL_PROXY = proxy
        end
        os.vrunv(is_host("windows") and "gclient.bat" or "gclient", {"--version"}, {envs = envs})
    end)
