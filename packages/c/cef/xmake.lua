package("cef")

    set_homepage("https://bitbucket.org/chromiumembedded")
    set_description("Chromium Embedded Framework (CEF). A simple framework for embedding Chromium-based browsers in other applications.")
    set_license("BSD-3-Clause")

    add_versions("v88.2.1", "8ed01da6327258536c61ada46e14157149ce727e7729ec35a30b91b3ad3cf555")

    set_urls("https://cef-builds.spotifycdn.com/cef_binary_$(version).tar.bz2", {version = function (version)
        if version == "v88.2.1" then
            return "88.2.1%2Bg0b18d0b%2Bchromium-88.0.4324.146_windows64"
        end
        return ""
    end})

    on_load("windows", function (package)
        if package:is_plat("windows") then
            package:add("deps", "cmake")
        end
    end)

    on_install("windows", function (package)
        os.cp("include", package:installdir())
        os.cp("Release/*", package:installdir("lib"), {rootdir = "bin"})
        import("package.tools.cmake").install(package, {})
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("CefEnableHighDPISupport()", {includes = "include/cef_app.h"}))
    end)
