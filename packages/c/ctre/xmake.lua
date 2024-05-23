package("ctre")

    set_homepage("https://github.com/hanickadot/compile-time-regular-expressions/")
    set_description("ctre is a Compile time PCRE (almost) compatible regular expression matcher.")

    set_urls("https://github.com/hanickadot/compile-time-regular-expressions/archive/refs/tags/v$(version).zip")
    add_versions("3.4.1", "099d6503cddd8e086b71247321ac64d91976136aa727d0de3ad5f9fd1897c5c7")
    add_versions("3.5", "335180eaa44d60cec0fec445bafad78509f03c6e8a8bd9d24591d4d38333f78d")
    add_versions("3.6", "f99f9c8bd3154d76305ef4fbde2c6622ed309c5a3401168732048fbc31e93f5d")
    add_versions("3.7.2", "1dbcd96d279b5be27e9c90d2952533db10bc0e5d8ff6224a3c6d538fd94ab18f")
    add_versions("3.8.1", "7c7a936145defe56e886bac7731ea16a52de65d73bda2b56702d0d0a61101c76")
    add_versions("3.9.0", "55778712968d4f3ad00e9d20fc4d2149d14d96b4ff3dab086613797cd2ccd2b2")

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
