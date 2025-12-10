package("double-conversion")
    set_homepage("https://github.com/google/double-conversion")
    set_description("Efficient binary-decimal and decimal-binary conversion routines for IEEE doubles.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/google/double-conversion/archive/refs/tags/$(version).tar.gz",
             "https://github.com/google/double-conversion.git")

    add_versions("v3.4.0", "42fd4d980ea86426e457b24bdfa835a6f5ad9517ddb01cdb42b99ab9c8dd5dc9")
    add_versions("v3.3.1", "fe54901055c71302dcdc5c3ccbe265a6c191978f3761ce1414d0895d6b0ea90e")
    add_versions("v3.3.0", "04ec44461850abbf33824da84978043b22554896b552c5fd11a9c5ae4b4d296e")
    add_versions("v3.1.5", "a63ecb93182134ba4293fd5f22d6e08ca417caafa244afaa751cbfddf6415b13")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                double_conversion::Double x;
            }
        ]]}, {configs = {languages = "c++11"}, includes = "double-conversion/ieee.h"}))
    end)
