package("wintoast")
    set_homepage("https://github.com/mohabouje/WinToast")
    set_description("WinToast is a lightly library written in C++ which brings a complete integration of the modern toast notifications of Windows 8, Windows 10 and Windows 11.")
    set_license("MIT")

    add_urls("https://github.com/mohabouje/WinToast/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mohabouje/WinToast.git")
    add_versions("v1.3.0", "998bd82fb2f49ee4b0df98774424d72c2bc18225188f251a9242af28bb80e6d4")

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
        local configs = {}
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
        #include "wintoastlib.h"
        using namespace WinToastLib;
        void test() {
            WinToastTemplate templ = WinToastTemplate(WinToastTemplate::Text01);
            templ.setTextField(L"Hello World", WinToastTemplate::FirstLine);
        }
        ]]}, {configs = {languages = "c++11"}}))
    end)
