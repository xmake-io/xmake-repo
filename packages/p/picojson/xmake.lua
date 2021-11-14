package("picojson")

    set_kind("library", {headeronly = true})
    set_homepage("https://pocoproject.org/")
    set_description("A header-file-only, JSON parser serializer in C++")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/kazuho/picojson/archive/refs/tags/$(version).tar.gz",
             "https://github.com/kazuho/picojson.git")
    add_versions("v1.3.0", "056805ca2691798f5545935a14bb477f2e1d827c9fb862e6e449dbea22801c7d")

    on_install(function (package)
        os.cp("picojson.h", package:installdir("include"))
    end)

    on_test(function(package)
        assert(package:check_cxxsnippets({
            test = [[
              static void test() {
                std::string json = "[ \"hello JSON\" ]";
                picojson::value v;
                std::string err = picojson::parse(v, json);
                if (! err.empty()) {
                  std::cerr << err << std::endl;
                }
              }
            ]]
        }, {configs = {languages = "c++11"}, includes = {"picojson.h"}}))
    end)
