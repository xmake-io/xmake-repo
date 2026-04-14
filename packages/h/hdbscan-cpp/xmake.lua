package("hdbscan-cpp")
    set_kind("library")
    set_homepage("https://github.com/rohanmohapatra/hdbscan-cpp")
    set_description("A C++ implementation of HDBSCAN clustering algorithm")
    set_license("MIT")

    add_urls("https://github.com/rohanmohapatra/hdbscan-cpp.git", { alias = "git" })

    add_versions("git:1.0.0", "1.0.0")
    add_versions("git:latest", "master")

    if is_plat("windows") then
        add_configs("shared", { description = "Build shared library.", default = false, type = "boolean", readonly = true })
    end

    on_install("macosx", "android", "linux", "windows", "mingw", function(package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function(package)
        assert(package:has_cxxfuncs("Hdbscan(std::string())", { includes = "Hdbscan/hdbscan.hpp"}))
    end)
