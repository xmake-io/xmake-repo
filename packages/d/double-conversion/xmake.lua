package("double-conversion")

    set_homepage("https://github.com/google/double-conversion")
    set_description("Efficient binary-decimal and decimal-binary conversion routines for IEEE doubles.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/google/double-conversion/archive/refs/tags/$(version).tar.gz",
             "https://github.com/google/double-conversion.git")
    add_versions("v3.3.0", "04ec44461850abbf33824da84978043b22554896b552c5fd11a9c5ae4b4d296e")
    add_versions("v3.1.5", "a63ecb93182134ba4293fd5f22d6e08ca417caafa244afaa751cbfddf6415b13")

    add_deps("cmake")
    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("double_conversion::Double", {includes = "double-conversion/ieee.h"}))
    end)
