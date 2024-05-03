package("functionalplus")
    set_kind("library", {headeronly = true})
    set_homepage("http://www.editgym.com/fplus-api-search/")
    set_description("Functional Programming Library for C++. Write concise and readable C++ code.")

    add_urls("https://github.com/Dobiasd/FunctionalPlus/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Dobiasd/FunctionalPlus.git")

    add_versions("v0.2.24", "446c63ac3f2045e7587f694501882a3d7c7b962b70bcc08deacf5777bdaaff8c")
    add_versions("v0.2.23", "5c2d28d2ba7d0cdeab9e31bbf2e7f8a9d6f2ff6111a54bfc11d1b05422096f19")
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
