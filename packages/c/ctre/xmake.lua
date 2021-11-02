package("ctre")

    set_homepage("https://github.com/hanickadot/compile-time-regular-expressions/")
    set_description("ctre is a Compile time PCRE (almost) compatible regular expression matcher.")

    set_urls("https://github.com/hanickadot/compile-time-regular-expressions/archive/refs/tags/v$(version).zip")
    add_versions("3.4.1", "099d6503cddd8e086b71247321ac64d91976136aa727d0de3ad5f9fd1897c5c7")

    add_configs("header_only", {description = "Use header only version.", default = false, type = "boolean"})

    on_load(function (package)
        if not package:config("header_only") then
            package:add("deps", "cmake")
        end
    end)

    on_install(function (package)
        if package:config("header_only") then
            os.cp("single-header", package:installdir("include"))
            return
        end
        local configs = {"-DCTRE_BUILD_TESTS=OFF"}
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include<ctll.hpp>
            #include<ctre.hpp>
            #include<iostream>
            #include<string>

            static void test() {
                std::string str = "Hello World";
                static constexpr auto pattern = ctll::fixed_string{ R"(\s+)" };
                for(auto e: ctre::split<pattern>(str)) {
                    std::cout << std::string(e.get<0>()) << std::endl;
                }
            }
        ]]}, {configs = {languages = "c++20"}, includes = "ctre.hpp"}))
    end)