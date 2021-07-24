package("abseil")

    set_homepage("https://abseil.io")
    set_description("C++ Common Libraries")

    add_urls("https://github.com/abseil/abseil-cpp/archive/$(version).tar.gz",
             "https://github.com/abseil/abseil-cpp.git")
    add_versions("20200225.1", "0db0d26f43ba6806a8a3338da3e646bb581f0ca5359b3a201d8fb8e4752fd5f8")
    add_versions("20210324.1", "441db7c09a0565376ecacf0085b2d4c2bbedde6115d7773551bc116212c2a8d6")
    add_versions("20210324.2", "59b862f50e710277f8ede96f083a5bb8d7c9595376146838b9580be90374ee1f")

    add_deps("cmake")

    on_install("macosx", "linux", "windows", function (package)
        local configs = {"-DCMAKE_CXX_STANDARD=17"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            #include <string>
            #include <vector>
            void test () {
                std::vector<std::string> v = {"foo","bar","baz"};
                std::string s = absl::StrJoin(v, "-");
                std::cout << "Joined string: " << s << "\\n";
            }
        ]]}, {configs = {languages = "c++17"}, includes = "absl/strings/str_join.h"}))
    end)
