package("yaml_cpp_struct")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/fantasy-peak/yaml_cpp_struct")
    set_description("It's easy to mapping yaml to cpp's struct")
    set_license("MIT")

    add_urls("https://github.com/fantasy-peak/yaml_cpp_struct/archive/refs/tags/$(version).tar.gz",
             "https://github.com/fantasy-peak/yaml_cpp_struct.git")

    add_versions("v1.0.2", "7635bb968690f97f9be420e42de2120b1101f0ab20173ddec8d24b5de16f25e5")
    add_versions("v1.0.4", "2ef2a087a12aa64a20e0ab98ec212d95a188d1fba1073ae15cd095e299a602f0")

    add_deps("cmake")
    add_deps("magic_enum", "visit_struct", "yaml-cpp")

    on_check("windows", function (package)
        local vs_toolset = package:toolchain("msvc"):config("vs_toolset")
        if vs_toolset then
            local vs_toolset_ver = import("core.base.semver").new(vs_toolset)
            local minor = vs_toolset_ver:minor()
            assert(minor and minor >= 30, "package(yaml_cpp_struct) require vs_toolset >= 14.3")
        end
    end)

    on_install(function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            struct Config {
                std::string name;
            };
            YCS_ADD_STRUCT(Config, name)
            void test() {
                auto [cfg, error] = yaml_cpp_struct::from_yaml<Config>("a.txt");
            }
        ]]}, {configs = {languages = "c++17"}, includes = {"yaml_cpp_struct.hpp"}}))
    end)
