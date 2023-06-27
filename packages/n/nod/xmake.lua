package("nod")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/fr00b0/nod")
    set_description("Small, header only signals and slots C++11 library.")
    set_license("MIT")

    add_urls("https://github.com/fr00b0/nod/archive/refs/tags/$(version).tar.gz",
             "https://github.com/fr00b0/nod.git")
    add_versions("v0.5.4", "21ec7e5ea5af9fc823f1a36f6981e307321f7b4f3fd8362620a7f3529fc19aed")

    on_install(function (package)
        os.cp("include/*", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            void test()
            { 
                nod::signal<void()> signal;
                signal.connect([](){
                    std::cout << "Hello, World!" << std::endl;
                });
                signal();
            }
        ]]}, {configs = {languages = "c++11"}, includes = { "nod/nod.hpp" } }))
    end)
