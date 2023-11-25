package("easywsclient")
    set_homepage("https://github.com/dhbaird/easywsclient")
    set_description("A short and sweet WebSocket client for C++")
    set_license("MIT")

    add_urls("https://github.com/dhbaird/easywsclient.git")
    add_versions("2021.01.12", "afc1d8cfc584e0f1f4a77e8c0ce3e979d9fe7ce2")
    add_patches("2021.01.12", path.join(os.scriptdir(), "patches", "2021.01.12", "fix_linux.patch"), "18712e9cd793ea256b5b4ad22e281f22251b50b6570cb8b0f969f4438e363035")

    on_install(function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("easywsclient")
                set_kind("$(kind)")
                set_languages("cxx11")
                add_files("easywsclient.cpp")
                add_headerfiles("(easywsclient.hpp)")
                if is_plat("windows") then
                    add_defines("_WIN32")
                end
        ]])
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "easywsclient.hpp"
            void test() {
                easywsclient::WebSocket::pointer ws = easywsclient::WebSocket::create_dummy();
                ws->send("Hello World!");
            }
        ]]}), {configs = {languages = "cxx11"}})
    end)
