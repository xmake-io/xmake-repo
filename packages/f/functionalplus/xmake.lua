package("functionalplus")
    set_kind("library", {headeronly = true})
    set_homepage("http://www.editgym.com/fplus-api-search/")
    set_description("Functional Programming Library for C++. Write concise and readable C++ code.")

    add_urls("https://github.com/Dobiasd/FunctionalPlus/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Dobiasd/FunctionalPlus.git")
    add_versions("v0.2.18-p0", "ffc63fc86f89a205accafa85c35790eda307adf5f1d6d51bb7ceb5c5e21e013b")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
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
