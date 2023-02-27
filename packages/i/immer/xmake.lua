package("immer")
    set_kind("library", {headeronly = true})

    set_homepage("https://github.com/arximboldi/immer")
    set_description("Library of persistent and immutable data structures written in C++.")
    set_license("BSL-1.0")

    add_urls("https://github.com/arximboldi/immer/archive/refs/tags/$(version).tar.gz",
             "https://github.com/arximboldi/immer.git")
    add_versions("v0.8.0", "4ed9e86a525f293e0ba053107b937d88b032674ec6e5db958816f2e412677fde")

    add_deps("cmake")

    on_install("windows", "linux", "macosx", function (package)
        local configs = {
            "-Dimmer_BUILD_TESTS=OFF",
            "-Dimmer_BUILD_EXAMPLES=OFF",
            "-Dimmer_BUILD_DOCS=OFF",
            "-Dimmer_BUILD_EXTRAS=OFF"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                const auto v0 = immer::vector<int>{};
                const auto v1 = v0.push_back(13);
                const auto v2 = v1.set(0, 42);
            }
        ]]}, {configs = {languages = "c++14"}, includes = "immer/vector.hpp"}))
    end)
