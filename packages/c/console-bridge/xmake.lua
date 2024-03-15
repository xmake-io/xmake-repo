package("console-bridge")

    set_homepage("https://github.com/ros/console_bridge")
    set_description("A ROS-independent package for logging that seamlessly pipes into rosconsole/rosout for ROS-dependent packages.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/ros/console_bridge/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ros/console_bridge.git")
    add_versions("1.0.1", "2ff175a9bb2b1849f12a6bf972ce7e4313d543a2bbc83b60fdae7db6e0ba353f")
    add_versions("1.0.2", "303a619c01a9e14a3c82eb9762b8a428ef5311a6d46353872ab9a904358be4a4")

    add_deps("cmake")
    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("console_bridge::LogLevel", {includes = "console_bridge/console.h"}))
    end)
