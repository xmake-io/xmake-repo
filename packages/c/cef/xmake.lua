package("cef")

    set_homepage("https://bitbucket.org/chromiumembedded")
    set_description("Chromium Embedded Framework (CEF). A simple framework for embedding Chromium-based browsers in other applications.")
    set_license("BSD-3-Clause")

    local buildver = {
        ["88.2.1"]  = "88.2.1+g0b18d0b+chromium-88.0.4324.146",
        ["88.2.9"]  = "88.2.9+g5c8711a+chromium-88.0.4324.182",
        ["90.5.3"]  = "90.5.3+gaf0e862+chromium-90.0.4430.72",
        ["91.1.22"] = "91.1.22+gc67b5dd+chromium-91.0.4472.124",
        ["97.1.9"] = "97.1.9+ga00bca5+chromium-97.0.4692.99",
        ["100.0.23"] = "100.0.23+ga1e2187+chromium-100.0.4896.127",
        ["100.0.24"] = "100.0.24+g0783cf8+chromium-100.0.4896.127"
    }
  
    if is_plat("windows") then
        add_urls("https://cef-builds.spotifycdn.com/cef_binary_$(version).tar.bz2", {version = function (version)
            return format("%s_windows%s", buildver[tostring(version)], (is_arch("x64") and "64" or "32"))
        end})
        if is_arch("x64") then
            add_versions("100.0.24", "c16329ff3beff7ab383d93fe5785eafe83dc3c0b34992cf28c59b0aa3f6fc7ec")
            add_versions("100.0.23", "6ba279186f5dc3487f1f89facdeaaa81efcdea90d8a8c4a89273e10262593fa1")
            add_versions("97.1.9", "b5f788df517aeac2b86d264440d26eec5c1eb803e66cf1f7cf38cabca3af6fa5")
            add_versions("91.1.22", "a01dd3f996061a8d0ddc1a2ab211340f9b3bb890eef3606329579b43101607dc")
            add_versions("90.5.3", "d92abe3e3d3aa2aa7bf25669fe7cb59a0232ee9eb14ad4f1ea60334f9485d0ef")
            add_versions("88.2.9", "86c01e38e7b7d59fed8a1e1ab2c3bfbcc1db42e21f8a6e6feb4061b2af7b1b7d")
            add_versions("88.2.1", "8ed01da6327258536c61ada46e14157149ce727e7729ec35a30b91b3ad3cf555")
        else
            add_versions("100.0.24", "ac26164edc67988d53c6e78dd19f42b429ac9ff4a3b197d9f2b416e8e0ace07c")
            add_versions("100.0.23", "93febdee82776122b982b1f620d74ce5572a5b7b75d882384634ede947a5b751")
            add_versions("97.1.9", "10c0af4b939b3ec6e0f072c2e3c15a044e20b8d42c799ee13a2730ac26dc0908")
            add_versions("91.1.22", "9f9ab6787f2d35024238aceab5d1eccf49e19e8bfe2519ca96610fe2bbe82ad1")
            add_versions("90.5.3", "8e49009a543273319ae51d58e1b78a1695f3864c5773cdfdf7f5994810d0874d")
            add_versions("88.2.9", "90c15421d6d7b970ca839b746d8e85c09f449ae37d87d07f42dd45dfe16df455")
            add_versions("88.2.1", "f608e4028478d4c87541c679f5cfe42bda0d459a80ee26acfe93f634c25e96ab")
        end
        add_configs("vs_runtime", {description = "Set vs compiler runtime.", default = "MT", type = "string", readonly = true})
    end

    add_patches("97.1.9", path.join(os.scriptdir(), "patches", "97.1.9", "msvc_cpp20.patch"), "28562870ae1dd30eaa42a9297ad76eae8f80422cdf3638674c80e51768fb520d")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})
    
    if is_plat("windows") then
        add_syslinks("user32", "advapi32", "shlwapi", "comctl32", "rpcrt4")
    end
    add_includedirs(".", "include")

    on_install("windows", function (package)
        local distrib_type = package:debug() and "Debug" or "Release"
        os.cp(path.join(distrib_type, "*.lib"), package:installdir("lib"))
        os.cp(path.join(distrib_type, "*.dll"), package:installdir("bin"))
        os.cp(path.join(distrib_type, "swiftshader", "*.dll"), package:installdir("bin", "swiftshader"))
        os.cp(path.join(distrib_type, "*.bin"), package:installdir("bin"))
        os.cp("Resources/*", package:installdir("bin"))
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("CefEnableHighDPISupport", {includes = "cef_app.h"}))
    end)
