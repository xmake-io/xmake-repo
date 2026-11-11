package("vexa")
    set_homepage("https://github.com/monjaris/vexa")
    set_description("Modern cross-platform game/graphics framework written in C++23")
    add_urls("https://github.com/monjaris/vexa.git")
    set_license("MIT")

    add_deps("tiny-fmt")

    on_install(function (package)
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <vexa/vexa.hpp>
            void test() {
                vexa::Window window;
                vexa::Image image;
                vexa::Font font;
                vexa::Texture texture;
            }
        ]]}, {configs = {languages = "c++23"}}))
    end)
