package("breakpad")
    set_homepage("https://chromium.googlesource.com/breakpad/breakpad")
    set_description("Mirror of Google Breakpad project")

    add_urls("https://github.com/google/breakpad/archive/refs/tags/$(version).tar.gz",
             "https://github.com/google/breakpad.git",
             "https://chromium.googlesource.com/breakpad/breakpad.git")

    add_versions("v2023.01.27", "f187e8c203bd506689ce4b32596ba821e1e2f034a83b8e07c2c635db4de3cc0b")

    if not is_plat("windows") then
        add_deps("autoconf", "automake", "libtool")
    end

    if is_plat("linux") then
        add_syslinks("pthread")
    elseif is_plat("windows") then
        add_syslinks("dbghelp")
    end

    on_install(function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_install("windows", function (package)
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
                    std::wstring name, dump_path;
                    google_breakpad::CrashGenerationServer crash_server(
                        name, nullptr, nullptr, nullptr, nullptr, nullptr,
                        nullptr, nullptr, nullptr, nullptr, true, &dump_path);
                }
            ]]
        elseif package:is_plat("linux") then
            plat = "linux"
        elseif package:is_plat("macosx") then
            plat = "mac"
        elseif package:is_plat("android") then
            plat = "android"
        else
            plat = "linux"
        end

        local header = "client/" .. plat .. "/crash_generation/crash_generation_server.h"
        assert(package:check_cxxsnippets({test = snippets}, {configs = {languages = "c++11"}, includes = header}))
    end)
