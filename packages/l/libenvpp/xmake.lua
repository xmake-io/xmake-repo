package("libenvpp")
    set_homepage("https://github.com/ph3at/libenvpp")
    set_description("A modern C++ library for type-safe environment variable parsing")
    set_license("Apache-2.0")

    add_urls("https://github.com/ph3at/libenvpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ph3at/libenvpp.git", {submodules = false})

    add_versions("v1.5.2", "6f341a52d2d12c831153e6b4e853e38a2c36a4da1ac3ec9626878a952d25a880")
    add_versions("v1.5.1", "3b369597958f01bf71e998e68f8909b49b870bb264f0914cb318a5597ebe548b")
    add_versions("v1.4.4", "aa5af7958092bf9546a144fe000313bef980302d5e311e5938e5b99845c701ea")
    add_versions("v1.4.3", "affbd735b6f47615a54c9159baef9de206cc85badb5af4f662669f3789a13fa8")
    add_versions("v1.4.2", "14b2e14112036b15c7fc2d7e566ee6b2de9c2c55091e8d3de194ebed19f6fc34")
    add_versions("v1.4.1", "1bcd0a1eb4eef32a53cbb410ae38d708ea662e491cc5536cb9b15d54cc8b5707")
    add_versions("v1.4.0", "3f9a4a4b62abc06522de76e3a999cc3cd6b60299dc26b28ccc2183aa614f10cd")
    add_versions("v1.1.0", "c373a6867ed915ffdacbbebfa017e03c0797dc4c2eb173659f607024e9cfbac9")

    add_configs("shared", {description = "Build shared binaries.", default = false, type = "boolean", readonly = true})

    add_deps("cmake")
    add_deps("fmt >=9.1.0", {configs = {header_only = false}})

    on_install(function (package)
        local version = package:version()
        if package:gitref() or version:ge("1.4.3") then
            io.replace("CMakeLists.txt", "fetch_content_from_submodule(fmt external/fmt)", "find_package(fmt REQUIRED CONFIG)\ninclude(CMakePackageConfigHelpers)", {plain = true})
        end

        local configs = {"-DLIBENVPP_EXAMPLES=OFF", "-DLIBENVPP_TESTS=OFF", "-DLIBENVPP_INSTALL=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLIBENVPP_CHECKS=" .. (package:is_debug() and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)

        if version or version:lt("1.4.3") then
            os.rm(package:installdir("include/fmt"))
            os.rm(package:installdir("lib/pkgconfig"))
            os.rm(package:installdir("lib/cmake/fmt"))
            os.rm(package:installdir("lib/fmt*"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <libenvpp/env.hpp>
            void test() {
                auto pre = env::prefix("MYPROG");
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
