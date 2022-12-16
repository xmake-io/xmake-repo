package("termcolor")
    set_kind("library", { headeronly = true })
    set_homepage("https://github.com/ikalnytskyi/termcolor")
    set_description("Termcolor is a header-only C++ library for printing colored messages to the terminal. Written just for fun with a help of the Force.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/ikalnytskyi/termcolor/archive/refs/tags/v$(version).zip",
                     "https://github.com/ikalnytskyi/termcolor.git")
    add_versions("2.1.0","435994c32557674469404cb1527c283fdcf45746f7df75fd2996bb200d6a759f")

    on_install(function(package)
        os.cp("include/termcolor/termcolor.hpp", package:installdir("include/termcolor"))
    end)

    on_test(function(package)
        assert(package:check_cxxsnippets({ test = [[
        void test() {
            std::cout << termcolor::red
                << "Hello World!"
                << termcolor::reset;
        }
        ]] }, { includes = "termcolor/termcolor.hpp" }))
    end)
