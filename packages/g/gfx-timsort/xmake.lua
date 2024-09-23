package("gfx-timsort")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/timsort/cpp-TimSort")
    set_description("A C++ implementation of timsort")
    set_license("MIT")

    add_urls("https://github.com/timsort/cpp-TimSort/archive/refs/tags/$(version).tar.gz",
             "https://github.com/timsort/cpp-TimSort.git")

    add_versions("v3.0.0", "d61b92850996305e5248d1621c8ac437c31b474f74907e223019739e2e556b1f")

    add_deps("cmake")

    if on_check then
        on_check(function (package)
            if package:is_plat("android") then
                local ndk = package:toolchain("ndk"):config("ndkver")
                assert(ndk and tonumber(ndk) > 22, "package(gfx-timsort) requires ndk version > 22")
            end

            assert(package:check_cxxsnippets({test = [[
                #include <vector>
                #include <algorithm>
                void test() {
                    std::vector<int> data;
                    auto lower = std::ranges::lower_bound(data, 0);
                }
            ]]}, {configs = {languages = "c++20"}}), "package(gfx-timsort) Require at least C++20.")
        end)
    end

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
