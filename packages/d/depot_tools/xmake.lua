package("depot_tools")
    set_kind("binary")
    set_homepage("https://chromium.googlesource.com/chromium/tools/depot_tools")
    set_description("Tools for working with Chromium development")

    add_urls("https://github.com/xmake-mirror/depot_tools.git",
             "https://chromium.googlesource.com/chromium/tools/depot_tools.git")
    add_versions("2022.2.1", "8a6d00f116d6de9d5c4e92acb519fd0859c6449a")

    on_load(function (package)
        package:addenv("PATH", ".")
        package:addenv("DEPOT_TOOLS_UPDATE", "0")
        package:addenv("DEPOT_TOOLS_METRICS", "0")
    end)

    on_install("linux", "macosx", "windows", function (package)
        os.cp("*", package:installdir())
    end)

    on_test(function (package)
        os.vrunv(package:is_plat("windows") and "gclient.bat" or "gclient", {"--version"})
    end)
