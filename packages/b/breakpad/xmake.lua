package("breakpad")
    set_homepage("https://chromium.googlesource.com/breakpad/breakpad")
    set_description("A set of client and server components which implement a crash-reporting system")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/google/breakpad/archive/refs/tags/$(version).tar.gz",
             "https://github.com/google/breakpad.git",
             "https://chromium.googlesource.com/breakpad/breakpad.git")

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
        add_syslinks("pthread")
    elseif is_plat("macosx") then
        add_frameworks("CoreFoundation")
    end

    add_deps("libdisasm")
    if is_plat("linux") then
        add_deps("linux-syscall-support")
    end

    on_install("windows|x64", "windows|x86", "linux", function (package)
        local files =
        {
            "src/processor/disassembler_x86.h",
            "src/processor/exploitability_win.cc"
        }
        if package:is_plat("linux") then
            table.insert(files, "src/common/linux/file_id.cc")
            table.insert(files, "src/common/memory_allocator.h")
            table.insert(files, "src/common/linux/safe_readlink.cc")
            table.insert(files, "src/common/linux/memory_mapped_file.cc")
            table.insert(files, "src/client/linux/log/log.cc")
            table.insert(files, "src/client/linux/handler/exception_handler.cc")
            table.insert(files, "src/client/linux/crash_generation/crash_generation_client.cc")
        end
        for _, file in ipairs(files) do
            io.replace(file, "third_party/", "", {plain = true})
        end

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
                    google_breakpad::ExceptionHandler handler(
                        descriptor, nullptr, nullptr, nullptr, false, 0);
                }
            ]]
        end

        local header = "client/" .. plat .. "/handler/exception_handler.h"
        assert(package:check_cxxsnippets({test = snippets}, {configs = {languages = "c++11"}, includes = header}))
    end)
