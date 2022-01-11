package("pupnp")
    set_homepage("https://pupnp.github.io/pupnp")
    set_description("Build UPnP-compliant control points, devices, and bridges on several operating systems.")

    add_urls("https://github.com/pupnp/pupnp/archive/refs/tags/release-$(version).tar.gz")
    add_versions("1.14.12", "6a7f26818d5aa3949bc2e68739387a261c564430ba612f793c61d31619dde1e4")

    add_deps("cmake")
    if is_plat("linux") then
        add_syslinks("pthread", "dl", "m")
    end

    on_install("linux", "macosx", function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DUPNP_BUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DUPNP_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("UpnpInit2", {includes = "upnp/upnp.h"}))
    end)
