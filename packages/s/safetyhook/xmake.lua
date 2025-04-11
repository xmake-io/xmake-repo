package("safetyhook")
    set_homepage("https://cursey.dev/safetyhook")
    set_description("C++23 procedure hooking library.")
    set_license("BSL-1.0")

    add_urls("https://github.com/cursey/safetyhook/archive/refs/tags/$(version).tar.gz",
             "https://github.com/cursey/safetyhook.git")

    add_versions("v0.6.5", "453e6c200fa9c5384ea3351f1e655759744909b3436d31bf00c003af8212352c")
    add_versions("v0.6.4", "57c2a7e23e9e0857eb0f5c6322d97d75147b579ae2b8831c821e6dbf6da04298")

    add_deps("cmake", "zydis 4.1.0")

    on_check(function (package)
        import("core.base.semver")
        if package:is_plat("windows") then
            local msvc = package:toolchain("msvc")
            if msvc then
                local vs_toolset = package:toolchain("msvc"):config("vs_toolset")
                assert(vs_toolset and semver.new(vs_toolset):minor() >= 30, "package(safetyhook): need vs_toolset >= v143")
            end
        end
        if not package:is_arch("i386", "x86", "x64", "x86_64") then 
            raise("package(safetyhook) only support x86 arch")
        end
    end)

    on_install("windows", "linux", "mingw", "msys", function (package)
        local configs = {"-DSAFETYHOOK_FETCH_ZYDIS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {packagedeps = {"zycore-c"}})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            SAFETYHOOK_NOINLINE int add(int x, int y) {
                return x + y;
            }

            SafetyHookInline g_add_hook{};

            int hook_add(int x, int y) {
                return g_add_hook.call<int>(x * 2, y * 2);
            }

            void test() {
                g_add_hook = safetyhook::create_inline(reinterpret_cast<void*>(add), reinterpret_cast<void*>(hook_add));
            }
        ]]}, {configs = {languages = "c++23"}, includes = "safetyhook.hpp"}))
    end)
