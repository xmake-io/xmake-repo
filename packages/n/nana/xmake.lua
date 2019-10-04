package("nana")

    set_homepage("http://nanapro.org")
    set_description("A modern C++ GUI library.")

    add_urls("https://github.com/cnjinhao/nana/archive/v$(version).tar.gz",
             "https://github.com/cnjinhao/nana.git")
    add_versions("1.6.2", "5f5cb791dff292e27bfa29d850b93f809a0d91d6044ea7e22ce7ae76a5d8b24e")
    add_versions("1.7.2", "e2efb3b7619e4ef3b6de93f8afc70ff477ec6cabf4f9740f0d786904c790613f")

    if is_plat("linux") then
        add_deps("cmake")
    end
    if is_plat("windows") then
        add_deps("cmake")
        add_deps("libjpeg")
        add_deps("libpng")
    end

    on_install("linux", "windows", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using namespace nana;
            void test() {
                form    fm;
                label   lb(fm, rectangle(fm.size()));
                lb.caption("Hello, World");
                fm.show();
                exec();
            }
        ]]}, {configs = {languages = "c++11"}, includes = {"nana/gui/wvl.hpp", "nana/gui/widgets/label.hpp"}}))
    end)
