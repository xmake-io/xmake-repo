package("zstr")
    set_kind("library", {headeronly = true})

    set_homepage("https://github.com/mateidavid/zstr")
    set_description("A C++ header-only ZLib wrapper.")
    set_license("MIT")

    add_urls("https://github.com/mateidavid/zstr/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mateidavid/zstr.git")
    add_versions("v1.1.0", "b77ef8b961233a100a34da588962a95a2f3b00c9b2dc0ea67100b36ec72128af")
    add_versions("v1.0.7", "8d2ddae68ff7bd0a6fce6150a8f52ad9ce1bed2c4056c8846f4dec4f2dc60819")

    add_patches("v1.0.7", "patches/fix-build-on-android-ndksdk-21.patch", "66468d9aab3443c488b7fadde7fb2547f1501c73d89e00c672834652ce61a047")

    add_deps("zlib")
    on_install(function (package)
        os.cp("src/*.hpp", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                std::stringbuf buf;
                zstr::ostream os{&buf};

                os << "Hello World!";
            }
        ]]}, {configs = {languages = "c++11"}, includes = "zstr.hpp"}))
    end)
