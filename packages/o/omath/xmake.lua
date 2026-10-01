package("omath")
    set_homepage("https://libomath.org/")
    set_description("Cross-platform modern general purpose math library written in C++23")
    set_license("zlib")

    add_urls("https://git.libomath.org/orange/omath/archive/$(version).tar.gz")

    add_versions("v5.6.0", "48cdf091451e7b999c0c49c7e979fdf61238bcadccd84a8be13135b8548f18c3")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end
    if is_arch("x86_64", "x64", "x86", "i386", "i686") then
        add_configs("avx2",  {description = "Enable AVX2", default = true, type = "boolean"})
    end
    add_configs("imgui", {description = "Define method to convert omath types to imgui types", default = true, type = "boolean"})
    add_configs("legacy", {description = "Enable legacy classes that MUST be used ONLY for backward compatibility", default = true, type = "boolean"})
    add_configs("supp", {description = "Supress some safety checks in release build to improve general performance", default = true, type = "boolean"})
    add_configs("inline", {description = "Force compiler to make some functions to be force inlined", default = true, type = "boolean"})
    add_configs("lua", {description = "Omath bindings for lua", default = true, type = "boolean"})
    if is_plat("windows", "linux", "mingw") then
        add_configs("hook", {description = "omath will HooksManager that can hook DirectX/OpenGL automatically", default = true, type = "boolean"})
    end
    add_configs("cppm", {description = "Build omath C++ module interface", default = true, type = "boolean"})

    add_deps("cmake")

    on_check(function (package)
        assert(package:check_cxxsnippets({test = [[
        template <typename T, T Min, T Max>
        struct Angle {
            static T get_min() { return Min; }
        };
        int main() {
            Angle<float, 0.0f, 180.0f> a;
            return 0;
        }
        ]]}, {configs = {languages = "c++23"}}), "package(omath): Your compiler does not support floating-point non-type template.")
    end)

    on_load(function (package)
        if package:config("imgui") then
            package:add("deps", "imgui")
            package:add("defines", "OMATH_IMGUI_INTEGRATION")
        end
        if package:is_arch("x86_64", "x64", "x86", "i386", "i686") and package:config("avx2") then
            package:add("defines", "OMATH_USE_AVX2")
        end
        if package:config("legacy") then
            package:add("defines", "OMATH_ENABLE_LEGACY")
        end
        if package:config("supp") then
            package:add("defines", "OMATH_SUPRESS_SAFETY_CHECKS")
        end
        if package:config("inline") then
            package:add("defines", "OMATH_ENABLE_FORCE_INLINE")
        end
        if package:config("lua") then
            package:add("deps", "lua", "sol2")
            package:add("defines", "OMATH_ENABLE_LUA")
        end
        if is_plat("windows", "linux", "mingw") and package:config("hook") then
            package:add("deps", "safetyhook")
            package:add("defines", "OMATH_ENABLE_HOOKING")
        end
    end)

    on_install(function (package)
        local configs = {
            "-DOMATH_STATIC_MSVC_RUNTIME_LIBRARY=OFF",
            "-DOMATH_USE_UNITY_BUILD=OFF",
            "-DOMATH_BUILD_TESTS=OFF",
            "-DOMATH_THREAT_WARNING_AS_ERROR=OFF",
            "-DOMATH_BUILD_BENCHMARK=OFF",
            "-DOMATH_BUILD_EXAMPLES=OFF",
            "-DOMATH_BUILD_VIA_VCPKG=OFF",
            "-DOMATH_ENABLE_COVERAGE=OFF"
        }
        table.insert(configs, "-DOMATH_USE_AVX2=" .. (package:config("avx2") and "ON" or "OFF"))
        table.insert(configs, "-DOMATH_IMGUI_INTEGRATION=" .. (package:config("imgui") and "ON" or "OFF"))
        table.insert(configs, "-DOMATH_ENABLE_LEGACY=" .. (package:config("legacy") and "ON" or "OFF"))
        table.insert(configs, "-DOMATH_SUPRESS_SAFETY_CHECKS=" .. (package:config("supp") and "ON" or "OFF"))
        table.insert(configs, "-DOMATH_ENABLE_FORCE_INLINE=" .. (package:config("inline") and "ON" or "OFF"))
        table.insert(configs, "-DOMATH_ENABLE_LUA=" .. (package:config("lua") and "ON" or "OFF"))
        table.insert(configs, "-DOMATH_ENABLE_HOOKING=" .. (package:config("hook") and "ON" or "OFF"))
        table.insert(configs, "-DOMATH_ENABLE_MODULES=" .. (package:config("cppm") and "ON" or "OFF"))
        if package:config("lua") then
            local lua = package:dep("lua")
            if lua then
                local fetchinfo = lua:fetch()
                if fetchinfo then
                    local includedirs = fetchinfo.includedirs or fetchinfo.sysincludedirs
                    if includedirs and #includedirs > 0 then
                        table.insert(configs, "-DLUA_INCLUDE_DIR=" .. includedirs[1])
                    end
                    local libfiles = fetchinfo.libfiles
                    if libfiles and #libfiles > 0 then
                        table.insert(configs, "-DLUA_LIBRARY=" .. libfiles[1])
                    end
                end
            end
            local sol2 = package:dep("sol2")
            if sol2 then
                local fetchinfo = sol2:fetch()
                if fetchinfo then
                    local includedirs = fetchinfo.includedirs or fetchinfo.sysincludedirs
                    if includedirs and #includedirs > 0 then
                        table.insert(configs, "-DSOL2_INCLUDE_DIRS=" .. includedirs[1])
                    end
                end
            end
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DOMATH_BUILD_AS_SHARED_LIBRARY=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #if __has_include(<omath/omath.hpp>)
                #include <omath/omath.hpp>
            #else
                #include <omath/vector2.hpp>
            #endif
            void test() {
                omath::Vector2 w = omath::Vector2(20.0, 30.0);
            }
        ]]}, {configs = {languages = "c++23"}}))
    end)
