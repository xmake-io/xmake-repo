package("breakpad")
    set_homepage("https://chromium.googlesource.com/breakpad/breakpad")
    set_description("Mirror of Google Breakpad project")

    add_urls("https://github.com/google/breakpad/archive/refs/tags/$(version).tar.gz",
             "https://github.com/google/breakpad.git",
             "https://chromium.googlesource.com/breakpad/breakpad.git")

    add_versions("v2023.06.01", "81555be3595e25e8be0fe6dd34e9490beba224296e0a8a858341e7bced67674d")
    add_versions("v2023.01.27", "f187e8c203bd506689ce4b32596ba821e1e2f034a83b8e07c2c635db4de3cc0b")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared binaries.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::breakpad")
    end

    if is_plat("windows") then
        add_syslinks("wininet", "dbghelp", "imagehlp")
    elseif is_plat("linux") then
        add_deps("autoconf", "automake", "m4", "libtool")
        add_deps("linux-syscall-support")
        add_syslinks("pthread")
        add_patches("v2023.06.01", path.join(os.scriptdir(), "patches", "v2023.06.01", "linux_syscall_support.patch"), "b61bf7bc138a3030259ad91b97a3eed73971595856255a17e7968d20d4b3877f")
    elseif is_plat("macosx") then
        add_deps("autoconf", "automake", "m4", "libtool")
        add_frameworks("CoreFoundation")
    end

    add_deps("libdisasm")

    on_install("windows|x64", "windows|x86", function (package)
        io.replace("src/processor/disassembler_x86.h", "third_party/", "", {plain = true})
        io.replace("src/processor/exploitability_win.cc", "third_party/", "", {plain = true})
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_install("linux", "macosx", function (package)
        print(os.curdir() , "is the xmake pkg install dir")
        io.replace("configure", "WARN_CXXFLAGS \" -Werror\"", "WARN_CXXFLAGS ", {plain = true})
        local configs = {"--disable-dependency-tracking"}
        if package:debug() then
            table.insert(configs, "-d")
        end
        import("package.tools.autoconf").install(package, configs, {packagedeps = "linux-syscall-support"})
        os.cp(package:installdir("include", "breakpad", "client"), package:installdir("include"))
        os.cp(package:installdir("include", "breakpad", "common"), package:installdir("include"))
        os.cp(package:installdir("include", "breakpad", "processor"), package:installdir("include"))
        os.cp(package:installdir("include", "breakpad", "google_breakpad"), package:installdir("include"))
        os.cp(package:installdir("include", "breakpad", "third_party"), package:installdir("include"))  
        print("fucking success")
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
        assert(package:check_cxxsnippets({test = snippets}, {configs = {languages = "c++17"}, includes = header, {packages = "breakpad"}}))
    end)
