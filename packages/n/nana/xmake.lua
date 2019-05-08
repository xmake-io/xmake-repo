package("nana")

    set_homepage("http://nanapro.org")
    set_description("A modern C++ GUI library.")

    add_urls("https://github.com/cnjinhao/nana/archive/v$(version).tar.gz",
             "https://github.com/cnjinhao/nana.git")
    add_versions("1.6.2", "5f5cb791dff292e27bfa29d850b93f809a0d91d6044ea7e22ce7ae76a5d8b24e")

    --[[ TODO
    on_install(function (package)
        import("package.tools.cmake").install(package)
    end)]]

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using namespace nana;
            form    fm;
            label   lb(fm, rectangle(fm.size()));
            lb.caption("Hello, World");
            fm.show();
            exec();
        ]]}, {configs = {languages = "c++11"}, includes = {"nana/gui/wvl.hpp", "nana/gui/widgets/label.hpp"}}))
    end)
