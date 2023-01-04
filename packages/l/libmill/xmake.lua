package("libmill")
    set_homepage("http://libmill.org")
    set_description("Go-style concurrency in C")

    set_urls("https://github.com/sustrik/libmill/archive/refs/tags/$(version).tar.gz",
             "https://github.com/sustrik/libmill.git")

    add_versions("1.18", "ff6903cd05f45c4cc050921d03201a93d2723ab59c480eb924f8f1ca8c6f0614")

    add_deps("autoconf", "automake")

    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            #include "libmill.h"
            static coroutine void switchtask(size_t count) {
                yield();
            }
            void test() {
                go(switchtask(0));
            }
        ]]}))
    end)
