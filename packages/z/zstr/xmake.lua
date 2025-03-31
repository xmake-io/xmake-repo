package("zstr")
    set_kind("library", {headeronly = true})

    set_homepage("https://github.com/mateidavid/zstr")
    set_description("A C++ header-only ZLib wrapper.")
    set_license("MIT")

    add_urls("https://github.com/mateidavid/zstr.git")
    add_versions("1.0.7", "755da7890ea22478a702e3139092e6c964fab1f5")

    add_patches("1.0.7", "patches/fix-build-on-android-ndksdk-21.patch", "66468d9aab3443c488b7fadde7fb2547f1501c73d89e00c672834652ce61a047")

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
