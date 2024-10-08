package("libmem")
    set_homepage("https://github.com/rdbo/libmem")
    set_description("Cross-platform game hacking library for C, C++, Rust, and Python, supporting process/memory hacking, hooking, detouring, and DLL/SO injection.")
    set_license("AGPL-3.0")

    add_urls(
        "https://github.com/rdbo/libmem/archive/refs/tags/$(version).tar.gz",
        "https://github.com/rdbo/libmem.git")
    add_versions("5.0.2", "99adea3e86bd3b83985dce9076adda16968646ebd9d9316c9f57e6854aeeab9c")
    add_deps("capstone", "keystone")

    if is_plat("windows") then
        add_syslinks("user32", "psapi", "ntdll", "shell32")
    elseif is_plat("linux") then
        add_syslinks("dl", "stdc++", "m")
    elseif is_plat("bsd") then
        add_syslinks("dl", "kvm", "procstat", "elf", "stdc++", "m")
    end

    on_load(function (package)
        if package:is_plat("windows") then
            package:add("defines", "LM_EXPORT")
        end
    end)

    on_install("windows", "linux", "freebsd", function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
        os.cp(path.join("include", "libmem"), package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cincludes("libmem/libmem.h"))
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
