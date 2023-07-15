package("polyhook2")
    set_homepage("https://github.com/stevemk14ebr/PolyHook_2_0")
    set_description("C++17, x86/x64 Hooking Libary v2.0")
    set_license("MIT")

    add_urls("https://github.com/stevemk14ebr/PolyHook_2_0.git")

    add_configs("shared_deps", {description = "Use shared library for dependency", default = false, type = "boolean"})

    on_install("windows|x86", "windows|x64", "linux|i386", "linux|x86_64", "macosx|i386", "macosx|x86_64", function (package)
        local configs = {}
        table.insert(configs, "-DPOLYHOOK_BUILD_SHARED_LIB=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DPOLYHOOK_BUILD_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        if package:config("shared_deps") then
            table.insert(configs, "-DPOLYHOOK_BUILD_SHARED_ASMTK=ON")
            table.insert(configs, "-DPOLYHOOK_BUILD_SHARED_ASMJIT=ON")
            table.insert(configs, "-DPOLYHOOK_BUILD_SHARED_ZYDIS=ON")
        end
        import("package.tools.cmake").install(package, configs, {buildir = "build"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            static void test() {
                PLH::NatDetour detour(0, 0, nullptr);
            }
        ]]}, {includes = "polyhook2/Detour/NatDetour.hpp", configs={languages = "c++17"}}))
    end)
