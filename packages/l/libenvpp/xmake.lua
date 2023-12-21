package("libenvpp")
    set_homepage("https://github.com/ph3at/libenvpp")
    set_description("A modern C++ library for type-safe environment variable parsing")
    set_license("Apache-2.0")

    add_urls("https://github.com/ph3at/libenvpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ph3at/libenvpp.git")

    add_versions("v1.1.0", "c373a6867ed915ffdacbbebfa017e03c0797dc4c2eb173659f607024e9cfbac9")

    add_configs("shared", {description = "Build shared binaries.", default = false, type = "boolean", readonly = true})

    add_deps("cmake")
    add_deps("fmt >=9.1.0", {configs = {header_only = false}})

    on_install(function (package)
        local configs = {"-DLIBENVPP_EXAMPLES=OFF", "-DLIBENVPP_TESTS=OFF", "-DLIBENVPP_INSTALL=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLIBENVPP_CHECKS=" .. (package:is_debug() and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        os.rm(package:installdir("include/fmt"))
        os.rm(package:installdir("lib/pkgconfig"))
        os.rm(package:installdir("lib/cmake/fmt"))
        os.rm(package:installdir("lib/fmt*"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <libenvpp/env.hpp>
            void test() {
                auto pre = env::prefix("MYPROG");
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
