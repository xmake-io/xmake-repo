package("snowhouse")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/banditcpp/snowhouse")
    set_description("An assertion library for C++")
    set_license("BSL-1.0")

    add_urls("https://github.com/banditcpp/snowhouse/archive/refs/tags/$(version).tar.gz",
             "https://github.com/banditcpp/snowhouse.git")

    add_versions("v5.0.0", "a1997eb1c170292bad5545ca5e65cb7c900bc49c0f9143672116777d24189b69")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[        
        #include <snowhouse/snowhouse.h>
        using namespace snowhouse;
        void test()
        {
            AssertThat(420, Is().EqualTo(420));
        }
        ]]}, {configs = {languages = "c++11"}}))
    end)
