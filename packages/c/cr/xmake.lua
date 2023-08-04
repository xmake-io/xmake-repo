package("cr")
    set_kind("library", {headeronly = true})
    set_homepage("https://fungos.github.io/cr-simple-c-hot-reload/")
    set_description("cr.h: A Simple C Hot Reload Header-only Library")
    set_license("MIT")

    add_urls("https://github.com/fungos/cr.git")
    add_versions("2022.11.06", "0e7fef63555cf73c70e4d9ae42f8a6e9cefb8e69")

    on_install(function (package)
        os.cp("cr.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #define CR_HOST
            #include <cr.h>
            void test() {
                cr_plugin ctx;
                cr_plugin_open(ctx, "c:/path/to/build/game.dll");
                cr_plugin_close(ctx);
            }
        ]]}))
    end)
