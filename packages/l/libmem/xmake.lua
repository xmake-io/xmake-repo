package("libmem")
    set_homepage("https://github.com/rdbo/libmem")
    set_description("Cross-platform game hacking library for C, C++, Rust, and Python, supporting process/memory hacking, hooking, detouring, and DLL/SO injection.")
    set_license("AGPL-3.0")

    add_urls("https://github.com/rdbo/libmem/archive/refs/tags/$(version).tar.gz",
            "https://github.com/rdbo/libmem.git")
    add_versions("5.0.4", "32b968fb2bd1e33ae854db3bd3fc9ce4374bd9e61ff420f365c52d5f7bbd85dd")
    add_versions("5.0.3", "75a190d1195c641c7d5d2c37ac79d8d1b5f18e43268d023454765a566d6f0d88")
    add_versions("5.0.2", "99adea3e86bd3b83985dce9076adda16968646ebd9d9316c9f57e6854aeeab9c")

    add_deps("capstone", "keystone")

    if is_plat("windows", "mingw") then
        add_syslinks("user32", "psapi", "ntdll", "shell32", "ole32")
        if is_plat("mingw") then
            add_syslinks("uuid")
        end
    elseif is_plat("linux") then
        add_syslinks("dl", "m")
    elseif is_plat("bsd") then
        add_syslinks("dl", "kvm", "procstat", "elf", "m")
    end

    on_load(function(package)
        if package:is_plat("windows") or package:config("shared") then
            package:add("defines", "LM_EXPORT")
        end
    end)

    on_install("windows", "linux", "bsd", function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            #include <libmem/libmem.h>
            void test() {
                lm_thread_t resultThread;
                lm_bool_t result = LM_GetThread(&resultThread);
            }
        ]]}, {configs = {languages = "c11"}}))

        assert(package:check_cxxsnippets({test = [[
            #include <libmem/libmem.hpp>
            #include <vector>
            #include <optional>
            using namespace libmem;
            void test() {
                std::optional<Thread> currentThread = GetThread();
                std::optional<std::vector<Thread>> threads = EnumThreads();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
