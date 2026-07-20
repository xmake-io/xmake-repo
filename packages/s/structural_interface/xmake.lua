package("structural_interface")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Maltose0118/structural_interface")
    set_description("Header-only C++26 library for structural interfaces and type erasure")
    set_license("MIT")

    add_urls("https://github.com/Maltose0118/structural_interface/archive/refs/tags/v$(version).tar.gz")
    add_versions("0.1.0", "a71b07193d9fdfc1bf74b5898a057331ead982ee8896567ea51761af4ba184e1")

    on_check(function(package)
        if not package:has_tool("cxx", "gxx") then
            raise("package(structural_interface): only gcc is supported")
        end
    end)

    on_install(function(package)
        os.cp("include", package:installdir())
    end)

    on_test(function(package)
        assert(package:check_cxxsnippets({test = [[
            #include <structural_interface.hpp>

            struct Drawable {
                void draw() const;
            };

            struct Circle {
                void draw() const {}
            };

            static_assert(si::satisfies<Circle, Drawable>);

            void test() {
                si::existential<Drawable> drawable = Circle{};
                drawable.draw();
            }
        ]]}, {
            configs = {
                languages = "c++26",
                cxflags = "-freflection",
                force = {
                    cxflags = "-freflection"
                }
            }
        }))
    end)
