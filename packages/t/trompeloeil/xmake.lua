package("trompeloeil")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/rollbear/trompeloeil")
    set_description("A thread-safe header-only mocking framework for C++11/14 using the Boost Software License 1.0")
    set_license("BSL-1.0")

    add_urls("https://github.com/rollbear/trompeloeil/archive/refs/tags/$(version).tar.gz")
    add_versions("v43", "86a0afa2e97347202a0a883ab43da78c1d4bfff0d6cb93205cfc433d0d9eb9eb")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            class Interface
            {
            public:
              virtual bool foo(int, std::string& s) = 0;
            };

            class Mock : public Interface
            {
            public:
              MAKE_MOCK2(foo, bool(int, std::string&),override);
            };
        ]]}, {configs = {languages = "c++14"}, includes = { "trompeloeil.hpp" }}))
    end)
