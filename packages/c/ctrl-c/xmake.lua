package("ctrl-c")
    set_homepage("https://github.com/evgenykislov/ctrl-c")
    set_description("Crossplatform code to handle Ctrl+C signal")
    set_license("MIT")

    add_urls("https://github.com/evgenykislov/ctrl-c.git")
    add_versions("2023.09.02", "98b39d689ecb1a7193a3647c9a7d58a521892f9b")

    on_install("windows", "macosx", "linux", "mingw", "android", "msys", "iphoneos", "cross", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("ctrl-c")
                set_kind("$(kind)")
                add_headerfiles("src/(ctrl-c.h)")
                add_files("src/ctrl-c.cpp")
                set_languages("c++11")
                if is_plat("windows") then
                    add_defines("_WIN32")
                end
                if is_plat("linux") then
                    add_defines("__linux__")
                end
                if is_plat("macosx") then
                    add_defines("__APPLE__")
                end
        ]])
        local configs = {}
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <ctrl-c.h>

            void test() {
                std::function<bool(enum CtrlCLibrary::CtrlSignal)> _exit = [](CtrlCLibrary::CtrlSignal signal) -> bool
                {
                    return true;
                };
                CtrlCLibrary::SetCtrlCHandler(_exit);
            }
        ]]}, {configs = {languages = "cxx11"}}))
    end)
