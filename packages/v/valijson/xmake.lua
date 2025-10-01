package("valijson")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/tristanpenman/valijson")
    set_description("Header-only C++ library for JSON Schema validation, with support for many popular parsers")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/tristanpenman/valijson/archive/refs/tags/$(version).tar.gz",
             "https://github.com/tristanpenman/valijson.git", {submodules = false})

    add_versions("v1.0.6", "bf0839de19510ff7792d8a8aca94ea11a288775726b36c4c9a2662651870f8da")

    add_configs("exceptions", {description = "Enable exception", default = true, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        if package:config("exceptions") then
            package:add("defines", "VALIJSON_USE_EXCEPTIONS=1")
        end
    end)

    on_install(function (package)
        io.replace("include/valijson/constraints/concrete_constraints.hpp", [[#include <cmath>]], [[#include <cmath>
#include <cstdint>]], {plain = true})
        local configs = {"-Dvalijson_BUILD_EXAMPLES=OFF", "-Dvalijson_BUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <valijson/schema.hpp>
            #include <valijson/schema_parser.hpp>
            void test() {
                valijson::Schema mySchema;
                valijson::SchemaParser parser;
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
