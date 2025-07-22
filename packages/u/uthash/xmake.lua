package("uthash")
    set_kind("library", {headeronly = true})
    set_homepage("https://troydhanson.github.io/uthash")
    set_description("C macros for hash tables and more")
    set_license("BSD")

    add_urls("https://github.com/troydhanson/uthash.git")
    add_versions("2025.05.05", "af6e637f19c102167fb914b9ebcc171389270b48")
    add_versions("2023.7.11", "ca98384ce7f30beb216f9a0bc88a3b4340ead729")

    on_install(function (package)
        os.cp("src/*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            #include <uthash.h>
            struct my_struct {
                int id;
                char name[10];
                UT_hash_handle hh;
            };
            struct my_struct *users = NULL;
            void test(struct my_struct *s) {
                HASH_ADD_INT( users, id, s );
            }
        ]]}))
    end)
