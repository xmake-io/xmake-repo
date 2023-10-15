package("breakpad")
    set_homepage("https://chromium.googlesource.com/breakpad/breakpad")
    set_description("Mirror of Google Breakpad project")

    add_urls("https://github.com/google/breakpad/archive/refs/tags/$(version).tar.gz",
             "https://github.com/google/breakpad.git",
             "https://chromium.googlesource.com/breakpad/breakpad.git")

    add_versions("v2023.01.27", "f187e8c203bd506689ce4b32596ba821e1e2f034a83b8e07c2c635db4de3cc0b")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::breakpad")
    end

    if is_plat("windows") then
        add_syslinks("wininet", "dbghelp", "imagehlp")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    elseif is_plat("macosx") then
        add_frameworks("CoreFoundation")
    end

    on_install(function (package)
        io.replace("src/processor/disassembler_x86.h", "third_party/", "", {plain = true})
        io.replace("src/processor/exploitability_win.cc", "third_party/", "", {plain = true})
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        local plat
        local snippets
        if package:is_plat("windows") then
            plat = "windows"
            snippets = [[
                void test() {
                    std::wstring dump_path;
                    google_breakpad::ExceptionHandler handler(dump_path, nullptr, nullptr, nullptr, 0);
                }
            ]]
        elseif package:is_plat("macosx") then
            plat = "mac"
            snippets = [[
                void test() {
                    std::string dump_path;
                    google_breakpad::ExceptionHandler handler(
                        dump_path, nullptr, nullptr, nullptr, false, nullptr);
                }
            ]]
        else
            plat = "linux"
            snippets = [[
                void test() {
                    google_breakpad::MinidumpDescriptor descriptor("/tmp");
                }
            ]]
        end

        local header = "client/" .. plat .. "/handler/exception_handler.h"
        assert(package:check_cxxsnippets({test = snippets}, {configs = {languages = "c++11"}, includes = header}))
    end)
