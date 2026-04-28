package("vamp-plugin-sdk")
    set_homepage("https://www.vamp-plugins.org")
    set_description("The SDK for Vamp plugins, an API for audio analysis and feature extraction plugins.")
    set_license("BSD-3-Clause AND MIT")

    add_urls("https://github.com/vamp-plugins/vamp-plugin-sdk.git")

    add_versions("2024.11.20", "44c2487763eb248a933e9eff9169cfadee375009")

    add_deps("cmake")

    on_install(function (package)
        if package:is_plat("windows") then
            io.replace("pkgconfig/vamp-hostsdk.pc.in", "-ldl", "", {plain = true})
        end
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("vhGetLibraryCount", {includes = "vamp-hostsdk/host-c.h"}))
    end)
