package("librime")
    set_homepage("https://rime.im")
    set_description("Rime Input Method Engine, the core library")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/rime/librime/archive/refs/tags/$(version).tar.gz",
             "https://github.com/rime/librime.git")

    add_versions("1.14.0", "b2b29c3551eec6b45af1ba8fd3fcffb99e2b7451aa974c1c9ce107e69ce3ea68")

    add_deps("cmake",
             "glog >=0.7",
             "leveldb",
             "marisa",
             "opencc >=1.0.2",
             "yaml-cpp >=0.5")

    add_deps("boost >=1.74", {configs = {regex = true, container = true}})
    on_install(function (package)
        local configs = {"-DBUILD_TEST=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("rime_get_api", {includes = "rime_api.h"}))
    end)
