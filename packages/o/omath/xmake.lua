package("omath")
    set_homepage("http://libomath.org")
    set_description("Cross-platform modern general purpose math library written in C++23")
    set_license("zlib")

    add_urls("https://github.com/orange-cpp/omath/archive/refs/tags/$(version).tar.gz",
             "https://github.com/orange-cpp/omath.git")

    add_versions("v3.0.3", "f72ec671eb99d83bf6d63ec5eee7436110a9f340b416eefac51464665bbda06c")

    add_configs("avx2",  {description = "Enable AVX2", default = true, type = "boolean"})
    add_configs("imgui", {description = "Define method to convert omath types to imgui types", default = true, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        if package:config("imgui") then
            package:add("deps", "imgui")
        end
    end)

    on_install(function (package)
        local configs = {"-DOMATH_THREAT_WARNING_AS_ERROR=OFF", "-DOMATH_BUILD_TESTS=OFF"}
        table.insert(configs, "-DOMATH_USE_AVX2=" .. (package:config("avx2") and "ON" or "OFF"))
        table.insert(configs, "-DOMATH_IMGUI_INTEGRATION=" .. (package:config("imgui") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DOMATH_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                omath::Vector2 w = omath::Vector2(20.0, 30.0);
            }
        ]]}, {configs = {languages = "c++23"}, includes = "omath/Vector2.hpp"}))
    end)
