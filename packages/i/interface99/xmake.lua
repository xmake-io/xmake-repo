package("interface99")
    set_kind("library", { headeronly = true })
    set_homepage("https://github.com/Hirrolot/interface99")
    set_description("Full-featured interfaces for C99")
    set_license("MIT")

    add_urls("https://github.com/Hirrolot/interface99/archive/refs/tags/v$(version).tar.gz",
        "https://github.com/Hirrolot/interface99.git")

    add_versions("1.0.0", "578c7e60fde4ea1c7fd3515e444c6a2e62a9095dac979516c0046a8ed008e3b2")
    add_versions("1.0.1", "ddc7cd979cf9c964a4313a5e6bdc87bd8df669142f29c8edb71d2f2f7822d9aa")

    add_deps("metalang99")

    on_install(function(package)
        os.cp("*.h", package:installdir("include"))
    end)

    on_test(function(package)
        assert(package:check_csnippets({test = [[
            #include <assert.h>
            #define Shape_IFACE                      \
                vfunc( int, perim, const VSelf)      \
                vfunc(void, scale, VSelf, int factor)
            interface(Shape);
            typedef struct {
                int a, b;
            } Rectangle;
            int Rectangle_perim(const VSelf) {
                VSELF(const Rectangle);
                return (self->a + self->b) * 2;
            }
            void Rectangle_scale(VSelf, int factor) {
                VSELF(Rectangle);
                self->a *= factor;
                self->b *= factor;
            }
            impl(Shape, Rectangle);
            void test() {
                Shape shape = DYN_LIT(Rectangle, Shape, {5, 7});
                assert(VCALL(shape, perim) == 24);
                VCALL(shape, scale, 5);
                assert(VCALL(shape, perim) == 120);
            }
        ]]}, { configs = { languages = "c11" }, includes = "interface99.h" }))
    end)
