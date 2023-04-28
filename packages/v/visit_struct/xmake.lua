package("visit_struct")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/cbeck88/visit_struct")
    set_description("A miniature library for struct-field reflection in C++")
    set_license("BSL-1.0")

    add_urls("https://github.com/cbeck88/visit_struct/archive/refs/tags/$(version).tar.gz",
             "https://github.com/garbageslam/visit_struct.git")
    add_versions('v1.1.0', '73a84f2d8a8844bc03a919163b27ee3b3f85d8c64f6151ce098ca50dbed6be51')

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            struct debug_printer {
                template <typename T>
                void operator()(const char * name, const T & t) const {
                  std::cout << "  " << name << ": " << t << std::endl;
                }
            };
            struct test_struct_one {
                int a;
                float b;
            };
            VISITABLE_STRUCT(test_struct_one, a, b);
            void test() {
                test_struct_one my_struct{ 5, 7.5f };
                visit_struct::for_each(my_struct, debug_printer{});
            }
        ]]}, {configs = {languages = "c++11"}, includes = {"visit_struct/visit_struct.hpp", "iostream"}}))
    end)
