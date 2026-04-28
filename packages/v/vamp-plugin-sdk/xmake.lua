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

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        --Exporting symbols isn't handled upstream; no visibility macros or such.
        if package:is_plat("windows") and package:config("shared") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("vhGetLibraryCount", {includes = "vamp-hostsdk/host-c.h"}))
    end)
