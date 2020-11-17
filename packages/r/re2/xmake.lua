package("re2")

    set_homepage("https://github.com/google/re2")
    set_description("RE2 is a fast, safe, thread-friendly alternative to backtracking regular expression engines like those used in PCRE, Perl, and Python. It is a C++ library.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/google/re2/archive/$(version).tar.gz", {version = function (version) return version:gsub("%.", "-") end})
    add_versions("2020.11.01", "8903cc66c9d34c72e2bc91722288ebc7e3ec37787ecfef44d204b2d6281954d7")

    if is_plat("windows") then
        add_deps("cmake")
    end

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_install("windows", function (package)
        local configs = {"-DRE2_BUILD_TESTING=OFF"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_install("macosx", "linux", function (package)
        local configs = {"prefix=" .. package:installdir()}
        import("package.tools.make").build(package, configs)
        if package:config("shared") then
            os.vrunv("make shared-install ", configs)
        else
            os.vrunv("make static-install ", configs)
        end
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
