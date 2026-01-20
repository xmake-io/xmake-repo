package("wintoast")
    set_homepage("https://github.com/mohabouje/WinToast")
    set_description("WinToast is a lightly library written in C++ which brings a complete integration of the modern toast notifications of Windows 8, Windows 10 and Windows 11.")
    set_license("MIT")

    add_urls("https://github.com/mohabouje/WinToast/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mohabouje/WinToast.git")

    add_versions("v1.3.2", "dc86beed1dd9b0e7a8524b434e46a9a53c414303aa5276a7fbaf3d0392735647")
    add_versions("v1.3.1", "3e060d3376fdfd9cd092e324f5d50dde9632e9f544295f4613c8e22078653ff0")
    add_versions("v1.3.0", "998bd82fb2f49ee4b0df98774424d72c2bc18225188f251a9242af28bb80e6d4")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    on_install("windows", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("c++11")
            target("wintoast")
                set_kind("$(kind)")
                add_headerfiles("include/(wintoastlib.h)")
                add_files("src/wintoastlib.cpp")
                add_includedirs("include")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
        #include "wintoastlib.h"
        using namespace WinToastLib;
        void test() {
            if (WinToast::isCompatible()) {
                WinToastTemplate templ = WinToastTemplate(WinToastTemplate::Text01);
                templ.setTextField(L"Hello World", WinToastTemplate::FirstLine);
            } else {
                std::cout << "Error, your system in not supported!" << std::endl;
            }
        }
        ]]}, {configs = {languages = "c++11"}}))
    end)
