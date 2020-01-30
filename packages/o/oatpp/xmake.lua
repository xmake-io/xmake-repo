package("oatpp")

    set_homepage("https://oatpp.io/")
    set_description("Modern Web Framework for C++. High performance, simple API, cross platform, zero dependency.")

    add_urls("https://github.com/oatpp/oatpp/archive/$(version).tar.gz",
             "https://github.com/oatpp/oatpp.git")

    add_versions("1.0.0", "9ba7c75e3ada8ec894ec10beae712e775774a835fd3de89d8c34e17740202619")

    add_deps("cmake")

    on_load(function (package)
        package:add("includedirs", path.join("include", "oatpp-" .. package:version_str(), "oatpp"))
    end)

    on_install("linux", "macosx", "windows", function (package)
        local configs = {"-DOATPP_BUILD_TESTS=OFF"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "oatpp/encoding/Base64.hpp"
            void test(int argc, char** argv) {
                oatpp::String message = "oat++ web framework";
                oatpp::String messageEncoded = "b2F0Kysgd2ViIGZyYW1ld29yaw==";
                {
                    oatpp::String encoded = oatpp::encoding::Base64::encode(message);
                    OATPP_ASSERT(encoded->equals(messageEncoded.get()));
                    oatpp::String decoded = oatpp::encoding::Base64::decode(encoded);
                    OATPP_ASSERT(message->equals(decoded.get()));
                }
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
