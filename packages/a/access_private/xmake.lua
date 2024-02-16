package("access_private")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/martong/access_private")
    set_description("Access private members and statics of a C++ class")
    set_license("MIT")

    add_urls("https://github.com/martong/access_private.git")
    add_versions("2024.02.01", "9e47d135067ecfe569158b2f42ead9c6db9aaedf")

    add_deps("cmake")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            class A {
                int m_i = 3;
                int m_f(int p) { return 14 * p; }
            };

            ACCESS_PRIVATE_FIELD(A, int, m_i)
            ACCESS_PRIVATE_FUN(A, int(int), m_f)

            void test() {
                A a;
                auto &i = access_private::m_i(a);
                auto res = call_private::m_f(a, 3);
            }
        ]]}, {configs = {languages = "cxx11"}}))
    end)
