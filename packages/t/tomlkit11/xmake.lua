package("tomlkit11")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/julixian/tomlkit11")
    set_description("Header-only C++11+ format-preserving TOML v1.1 library")
    set_license("Apache-2.0")

    add_urls("https://github.com/julixian/tomlkit11/archive/refs/tags/$(version).tar.gz",
             "https://github.com/julixian/tomlkit11.git")

    add_versions("v1.0.0", "68057bb16197287a2358f133897ac7d45b696338a638a7b1453a21abd566482d")

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DTOMLKIT11_BUILD_TESTS=OFF", "-DTOMLKIT11_BUILD_TOOLS=OFF"}
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        local languages = "c++11"
        if package:is_plat("windows") and package:has_tool("cxx", "clang", "clangxx") then
            languages = "c++14"
        end
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto doc = tomlkit::parse("key = 42\n");
                doc["key"] = 7;
                auto out = doc.toToml();
                (void)out;
            }
        ]]}, {configs = {languages = languages}, includes = "tomlkit11/tomlkit11.hpp"}))
    end)
