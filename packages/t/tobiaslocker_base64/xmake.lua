package("tobiaslocker_base64")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/tobiaslocker/base64")
    set_description("A modern C++ base64 encoder / decoder ")
    set_license("MIT")

    add_urls("https://github.com/tobiaslocker/base64.git")
    add_versions("2024.02.26", "387b32f337b83d358ac1ffe574e596ba99c41d31")

    on_install("windows|!arm64 or !windows", function (package)
        os.cp("include/base64.hpp", package:installdir("include/tobiaslocker_base64"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            #include <tobiaslocker_base64/base64.hpp>
            void test() {
                auto encoded_str =  base64::to_base64("Hello, World!");
                std::cout << encoded_str << std::endl;
                auto decoded_str = base64::from_base64("SGVsbG8sIFdvcmxkIQ==");
                std::cout << decoded_str << std::endl;
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
