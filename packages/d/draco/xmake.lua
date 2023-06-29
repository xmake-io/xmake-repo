package("draco")

    set_homepage("https://google.github.io/draco/")
    set_description("Draco is an open-source library for compressing and decompressing 3D geometric meshes and point clouds.")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/draco/archive/refs/tags/$(version).tar.gz",
             "https://github.com/google/draco.git")
    add_versions("1.4.1", "83aa5637d36a835103a61f96af7ff04c6d6528e643909466595d51ee715417a9")
    add_versions("1.5.0", "81a91dcc6f22170a37ef67722bb78d018e642963e6c56e373560445ce7468a20")
    add_versions("1.5.6", "2cc1f0904545e2a5d1f8fa060509e454bfd59363dff9263dbe0601571594279b")

    add_deps("cmake")
    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DCMAKE_INSTALL_LIBDIR=lib"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("draco::Status", {configs = {languages = "c++17"}, includes = {"iostream", "draco/core/status.h"}}))
    end)
