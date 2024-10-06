package("libmem")

    set_homepage("https://github.com/rdbo/libmem")
    set_description("Cross-platform game hacking library for C, C++, Rust, and Python, supporting process/memory hacking, hooking, detouring, and DLL/SO injection.")
    set_license("AGPL-3.0")

    add_urls("https://github.com/rdbo/libmem.git", {submodules = true})
    --add_urls("https://github.com/rdbo/libmem/archive/refs/tags/$(version).tar.gz", {submodules = true}) 
    add_versions("5.0.2", "99adea3e86bd3b83985dce9076adda16968646ebd9d9316c9f57e6854aeeab9c")
    add_deps("cmake", "vcpkg::capstone", "vcpkg::keystone") -- "vcpkg::llvm 11.1.0"
    on_install(function (package)
        local configs = {
            build_tests = package:config("build_tests"),
            deep_tests = package:config("deep_tests"),
            build_static = package:config("build_static")
        }

        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #pragma comment(lib, "ntdll.lib")
            #pragma comment(lib, "Shell32.lib")
            #pragma comment(lib, "keystone.lib")
            #pragma comment(lib, "capstone.lib")
            #pragma comment(lib, "libmem.lib")
            #include <libmem/libmem.hpp>
            #include <vector>
            #include <optional>
            using namespace libmem;
            void test() {
                std::optional<Thread> currentThread = GetThread();
                std::optional<std::vector<Thread>> threads = EnumThreads();

            }
            ]]}, {configs = {languages = "c++20"}}))
    end)
