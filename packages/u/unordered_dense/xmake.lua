package("unordered_dense")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/martinus/unordered_dense")
    set_description("A fast & densely stored hashmap and hashset based on robin-hood backward shift deletion.")
    set_license("MIT")

    add_urls("https://github.com/martinus/unordered_dense/archive/refs/tags/$(version).tar.gz",
             "https://github.com/martinus/unordered_dense.git")
    add_versions("v1.1.0", "b47d8590afdc32b306272a6bcb15d5464462f3cd3d44653648924a1e10d1e78c")

    add_deps("meson")
    on_install(function (package)
        import("package.tools.meson").install(package, {})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                ankerl::unordered_dense::map<int, int> map;
                map[123] = 333;
            }
        ]]}, {configs = {languages = "c++17"}, includes = "ankerl/unordered_dense.h"}))
    end)
