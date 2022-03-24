package("re2")

    set_homepage("https://github.com/google/re2")
    set_description("RE2 is a fast, safe, thread-friendly alternative to backtracking regular expression engines like those used in PCRE, Perl, and Python. It is a C++ library.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/google/re2/archive/$(version).tar.gz", {version = function (version) return version:gsub("%.", "-") end})
    add_versions("2020.11.01", "8903cc66c9d34c72e2bc91722288ebc7e3ec37787ecfef44d204b2d6281954d7")
    add_versions("2021.06.01", "26155e050b10b5969e986dab35654247a3b1b295e0532880b5a9c13c0a700ceb")
    add_versions("2021.08.01", "cd8c950b528f413e02c12970dce62a7b6f37733d7f68807e73a2d9bc9db79bc8")
    add_versions("2021.11.01", "8c45f7fba029ab41f2a7e6545058d9eec94eef97ce70df58e92d85cfc08b4669")
    add_versions("2022.02.01", "9c1e6acfd0fed71f40b025a7a1dabaf3ee2ebb74d64ced1f9ee1b0b01d22fd27")

    add_deps("cmake")

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_install(function (package)
        local configs = {"-DRE2_BUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <string>
            #include <cassert>
            void test() {
                int i;
                std::string s;
                assert(RE2::FullMatch("ruby:1234", "(\\w+):(\\d+)", &s, &i));
                assert(s == "ruby");
                assert(i == 1234);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "re2/re2.h"}))
    end)
