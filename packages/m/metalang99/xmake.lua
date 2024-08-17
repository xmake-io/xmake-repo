package("metalang99")
    set_kind("library", { headeronly = true })
    set_homepage("https://github.com/Hirrolot/metalang99")
    set_description("Full-blown preprocessor metaprogramming")
    set_license("MIT")

    add_urls("https://github.com/Hirrolot/metalang99/archive/refs/tags/v$(version).tar.gz",
        "https://github.com/Hirrolot/metalang99.git")

    add_versions("1.13.2", "912c6d91b872d34d2b6580d25afc38faccacf6c57462ab1c862010ff4afbf790")
    add_versions("1.13.3", "91fe8d4edcc2e7f91c5b567a2b90f2e30c2373f1ebbabcf209ea0d74f63bc1e9")

    on_install(function(package)
        os.cp("include", package:installdir())
    end)

    on_test(function(package)
        assert(package:check_csnippets({test = [[
            typedef struct {
                double width, height;
            } Rect;
            #define Rect_new(...) ML99_OVERLOAD(Rect_new_, __VA_ARGS__)
            #define Rect_new_1(x) { x, x }
            #define Rect_new_2(x, y) { x, y }
            static Rect ra = Rect_new(7, 8);
            static Rect rb = Rect_new(10);
        ]]}, { configs = { languages = "c11" }, includes = "metalang99.h" }))
    end)
