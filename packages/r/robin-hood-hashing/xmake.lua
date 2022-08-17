package("robin-hood-hashing")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/martinus/robin-hood-hashing")
    set_description("Fast & memory efficient hashtable based on robin hood hashing for C++11/14/17/20")
    set_license("MIT")

    add_urls("https://github.com/martinus/robin-hood-hashing/archive/refs/tags/$(version).tar.gz",
             "https://github.com/martinus/robin-hood-hashing.git")
    add_versions("3.11.3", "dcf2b7fa9ef9dd0c67102d94c28e8df3effbe1845e0ed1f31f4772ca5e857fc4")
    add_versions("3.11.5", "7aa183252527ded7f46186c1e2f4efe7d6139a3b7c0869c1b6051bd7260587ed")

    on_load(function (package)
        cprint("${yellow} Package deprecated, author reason:\nUnfortunately I do not have time to continue development for this hashmap. I have a worthy successor though, please head over to: ankerl::unordered_dense::{map, set}${clear}")
    end)

    add_deps("cmake")
    on_install(function (package)
        import("package.tools.cmake").install(package, {"-DRH_STANDALONE_PROJECT=OFF"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                robin_hood::unordered_flat_map<int, int> map;
                map[123] = 333;
            }
        ]]}, {configs = {languages = "c++14"}, includes = "robin_hood.h"}))
    end)
