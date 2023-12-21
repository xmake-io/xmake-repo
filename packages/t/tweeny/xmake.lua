package("tweeny")
    set_kind("library", {headeronly = true})
    set_homepage("http://mobius3.github.io/tweeny")
    set_description("A modern C++ tweening library")
    set_license("MIT")

    add_urls("https://github.com/mobius3/tweeny.git")

    add_versions("2023.05.09", "56aab8d0f9ee516c7b6014ba5212b5551efb590e")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <tweeny.h>
            void test() {
                auto helloworld = tweeny::from('h','e','l','l','o').to('w','o','r','l','d').during(50);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
