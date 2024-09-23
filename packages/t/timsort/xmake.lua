package("timsort")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/timsort/cpp-TimSort")
    set_description("A C++ implementation of timsort")
    set_license("MIT")

    add_urls("https://github.com/timsort/cpp-TimSort/archive/refs/tags/$(version).tar.gz",
             "https://github.com/timsort/cpp-TimSort.git")

    add_versions("v3.0.0", "d61b92850996305e5248d1621c8ac437c31b474f74907e223019739e2e556b1f")

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <string>
            #include <vector>
            #include <gfx/timsort.hpp>

            size_t len(const std::string& str) {
                return str.size();
            }
            void test() {
                std::vector<std::string> collection;
                gfx::timsort(collection, {}, &len);
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
