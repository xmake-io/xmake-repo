package("polyhook2")
    set_homepage("https://github.com/stevemk14ebr/PolyHook_2_0")
    set_description("C++20, x86/x64 Hooking Libary v2.0")
    set_license("MIT")

    add_urls("https://github.com/stevemk14ebr/PolyHook_2_0.git")
    
    add_versions("2023.7.15", "0d4d90e35ecc8ead9940c23cd29e7d8952b1bcb6")
    add_versions("2024.8.1", "19e7cec8cce4a0068f6db04b6d3680c078183002")

    add_configs("shared_deps", {description = "Use shared library for dependency", default = false, type = "boolean"})

    add_deps("cmake")

    on_install("windows|x86", "windows|x64", "linux|i386", "linux|x86_64", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DPOLYHOOK_BUILD_SHARED_LIB=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            local static_runtime = package:has_runtime("MT", "MTd")
            table.insert(configs, "-DPOLYHOOK_BUILD_STATIC_RUNTIME=" .. (static_runtime and "ON" or "OFF"))
            if not static_runtime then
                table.insert(configs, "-DPOLYHOOK_BUILD_SHARED_ASMTK=ON")
                table.insert(configs, "-DPOLYHOOK_BUILD_SHARED_ASMJIT=ON")
            end
        end
        if package:config("shared_deps") then
            if not package:is_plat("windows") then
                table.insert(configs, "-DPOLYHOOK_BUILD_SHARED_ASMTK=ON")
                table.insert(configs, "-DPOLYHOOK_BUILD_SHARED_ASMJIT=ON")
            end
            table.insert(configs, "-DPOLYHOOK_BUILD_SHARED_ZYDIS=ON")
        end
        import("package.tools.cmake").install(package, configs, {buildir = "build"})
        package:add("links", "PolyHook_2", "asmtk", "asmjit", "Zycore", "Zydis")
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            static void test() {
                PLH::NatDetour detour(0, 0, nullptr);
            }
        ]]}, {includes = "polyhook2/Detour/NatDetour.hpp", configs={languages = "c++17"}}))
    end)
