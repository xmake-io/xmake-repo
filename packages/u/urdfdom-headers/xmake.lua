package("urdfdom-headers")

    set_kind("library", {headeronly = true})
    set_homepage("http://ros.org/wiki/urdf")
    set_description("Headers for URDF parsers")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/ros/urdfdom_headers/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ros/urdfdom_headers.git")
    add_versions("1.0.5", "76a68657c38e54bb45bddc4bd7d823a3b04edcd08064a56d8e7d46b9912035ac")
    add_versions("1.1.1", "b2ee5bffa51eea4958f64479b4fa273881d82a3bfa1d98686a16f8d8ca6c2350")

    add_patches("1.0.5", path.join(os.scriptdir(), "patches", "1.0.5", "export.patch"), "c7c15c0fba7b618c4ff9207a561caae70374e642a779fb346f2c084d5da6ed8b")

    add_deps("cmake")
    on_install(function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("urdf::World", {includes = "urdf_world/world.h"}))
    end)
