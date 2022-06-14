package("h5cpp")
    set_homepage("https://ess-dmsc.github.io/h5cpp/")
    set_description("C++ wrapper for the HDF5 C-library")
    set_license("LGPL-2.1")

    add_urls("https://github.com/ess-dmsc/h5cpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ess-dmsc/h5cpp.git")
    add_versions("v0.5.1", "8fcab57ffbc2d799fe315875cd8fcf67e8b059cccc441ea45a001c03f6a9fd25")

    add_deps("cmake")
    add_deps("hdf5")

    on_install(function (package)
        local configs = {"-DH5CPP_WITH_BOOST=OFF", "-DH5CPP_CONAN=DISABLE"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("foo", {includes = "foo.h"}))
    end)
