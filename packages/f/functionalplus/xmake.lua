package("functionalplus")
    set_kind("library", {headeronly = true})
    set_homepage("http://www.editgym.com/fplus-api-search/")
    set_description("Functional Programming Library for C++. Write concise and readable C++ code.")

    add_urls("https://github.com/Dobiasd/FunctionalPlus/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Dobiasd/FunctionalPlus.git")

    add_versions("v0.2.22", "79378668dff6ffa8abc1abde2c2fe37dc6fe1ac040c55d5ee7886924fa6a1376")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <fplus/fplus.hpp>
            #include <vector>
            bool func()
            {
                std::vector<std::string> things = {"same old", "same old"};
                return fplus::all_the_same(things);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
