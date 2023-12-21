package("sonic-cpp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/bytedance/sonic-cpp")
    set_description("A fast JSON serializing & deserializing library, accelerated by SIMD.")
    set_license("Apache-2.0")

    add_urls("https://github.com/bytedance/sonic-cpp/archive/refs/tags/v$(version).zip")
    add_versions("1.0.0", "409441bfc8b8b9fea8641dc0a0cdfaeed784246066a5c49fc7d6e74c39999f7b")

    add_cxxflags("-march=haswell")

    on_install("linux", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "sonic/sonic.h"
            #include <string>

            void test()
            {
                std::string json = R"(
                    {
                    "a": 1,
                    "b": 2
                    }
                )";

                sonic_json::Document doc;
                doc.Parse(json);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
