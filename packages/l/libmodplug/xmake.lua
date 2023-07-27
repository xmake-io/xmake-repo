package("libmodplug")
    set_homepage("http://modplug-xmms.sf.net")
    set_description("libmodplug GitHub repository")
    set_license("Public Domain")

    add_urls("https://github.com/Konstanty/libmodplug.git")
    add_versions("2022.1.31", "d1b97ed0020bc620a059d3675d1854b40bd2608d")

    if is_plat("windows") then
        add_syslinks("user32")
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.insert(configs, "-DBUILD_SHARED_LIBS=ON")
        else
            table.insert(configs, "-DBUILD_SHARED_LIBS=OFF")
            package:add("defines", "MODPLUG_STATIC")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("ModPlug_Load", {includes = "libmodplug/modplug.h"}))
    end)
