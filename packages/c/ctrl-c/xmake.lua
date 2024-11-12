package("ctrl-c")
    set_homepage("https://github.com/evgenykislov/ctrl-c")
    set_description("Crossplatform code to handle Ctrl+C signal")
    set_license("MIT")

    add_urls("https://github.com/evgenykislov/ctrl-c/archive/refs/tags/$(version).tar.gz",
             "https://github.com/evgenykislov/ctrl-c.git")

    add_versions("v1.0.0", "9f63ff2e02ac62a19e30208af746d5a2655ecf040773b6c7d1e27e85be45ee1a")

    on_install("!bsd and !wasm", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("c++11")
            target("ctrl-c")
                set_kind("$(kind)")
                add_files("src/*.cpp")
                add_headerfiles("src/*.h")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        import("package.tools.xmake").install(package)
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
