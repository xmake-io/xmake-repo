package("robin-map")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Tessil/robin-map")
    set_description("A C++ implementation of a fast hash map and hash set using robin hood hashing")
    set_license("MIT")

    add_urls("https://github.com/Tessil/robin-map/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Tessil/robin-map.git")

    add_versions("v1.4.1", "0e3f53a377fdcdc5f9fed7a4c0d4f99e82bbb64175233bd13427fef9a771f4a1")
    add_versions("v1.4.0", "7930dbf9634acfc02686d87f615c0f4f33135948130b8922331c16d90a03250c")
    add_versions("v1.3.0", "a8424ad3b0affd4c57ed26f0f3d8a29604f0e1f2ef2089f497f614b1c94c7236")
    add_versions("v1.2.2", "c72767ecea2a90074c7efbe91620c8f955af666505e22782e82813c652710821")
    add_versions("v1.2.1", "2b54d2c1de2f73bea5c51d5dcbd64813a08caf1bfddcfdeee40ab74e9599e8e3")
    add_versions("v0.6.3", "e6654c8c2598f63eb0b1d52ff8bdf39cfcc91d81dd5d05274a6dca91241cd72f")

    add_deps("cmake")
    on_install(function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        local languages
        if package:version() and package:version():ge("1.4.0") then
            languages = "c++17"
        else
            languages = "c++11"
        end
        assert(package:check_cxxsnippets({test = [[
            void test() {
                tsl::robin_map<int, int> map = {{1, 1}, {2, 1}, {3, 1}};
                for (auto it = map.begin(); it != map.end(); ++it) {
                    it.value() = 2;
                }
            }
        ]]}, {configs = {languages = languages}, includes = "tsl/robin_map.h"}))
    end)
