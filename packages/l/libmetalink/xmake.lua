package("libmetalink")
    set_homepage("https://github.com/metalink-dev/libmetalink")
    set_description("C library to read Metalink XML download description format")
    set_license("MIT")

    add_urls("https://github.com/metalink-dev/libmetalink.git")

    add_versions("2015.07.07", "5bcdfc0572fccc2b7bde32693f0dddb6ca040549")

    add_deps("expat")

    on_install("windows", "linux", "macosx", "android", "mingw", "cross", function (package)
        if package:is_plat("windows") then
            os.cp(path.join(package:scriptdir(), "port", "unistd.h"), "unistd.h")
        end
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        os.cp(path.join(package:scriptdir(), "port", "config.h.in"), "config.h.in")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("metalink_get_version", {includes = "metalink/metalink.h"}))
    end)
