package("yalantinglibs")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/alibaba/yalantinglibs")
    set_description("A collection of modern C++ libraries")
    set_license("Apache-2.0")

    set_urls("https://github.com/alibaba/yalantinglibs/archive/refs/tags/$(version).zip",
             "https://github.com/alibaba/yalantinglibs.git")

    add_versions("0.3.4", "88ba1ae2aa828383e51af95dbd029f90d16d5428d868739c8c91de3f31bed70b")
    add_configs("ssl", {description = "Enable SSL", default = false, type = "boolean"})

    add_deps("asio", "async_simple")

    on_load(function (package)
        if package:config("ssl")then
            package:add("deps", "openssl3")
        end
    end)

    on_install("linux", "macos", "windows", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "ylt/struct_pack.hpp"
            struct person {
                int64_t id;
                std::string name;
                int age;
                double salary;
            };
            void test() {
                person person1{.id = 1, .name = "hello struct pack", .age = 20, .salary = 1024.42};
                std::vector<char> buffer = struct_pack::serialize(person1);
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
