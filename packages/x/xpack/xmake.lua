package("xpack")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/xyz347/xpack")
    set_description("convert json/xml/bson to c++ struct")
    set_license("Apache-2.0")

    add_urls("https://github.com/xyz347/xpack/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xyz347/xpack.git")

    add_versions("v1.0.6", "76ccd82b0f0ddaae93d2340b2fa49e3245c2eb15c147f4736e27e8b05616085d")
    add_versions("v1.0.5", "ea8693dd3a53d54e0c1e3c9e6e06f31ff7f593f7f8cf8fb4889f5c3354dbae8e")

    add_deps("rapidjson", "rapidxml")

    on_install(function (package)
        os.cp("*.h", package:installdir("include", "xpack"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <xpack/json.h>
            struct User {
                int id;
                std::string name;
                XPACK(O(id, name));
            };
            void test() {
                User u;
                std::string data = "{\"id\":12345, \"name\":\"xpack\"}";
                xpack::json::decode(data, u);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
