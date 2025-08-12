package("omath")
    set_homepage("http://libomath.org")
    set_description("Cross-platform modern general purpose math library written in C++23")
    set_license("zlib")

    add_urls("https://github.com/orange-cpp/omath/archive/refs/tags/$(version).tar.gz",
             "https://github.com/orange-cpp/omath.git", {submodules = false})

    add_versions("v3.0.3", "f72ec671eb99d83bf6d63ec5eee7436110a9f340b416eefac51464665bbda06c")
    add_versions("v3.2.0", "ecc474076df4c4435ab3aabe608b7c9e57c00d25dfdda8ff75197e49cba7f1bf")

    add_configs("avx2",  {description = "Enable AVX2", default = true, type = "boolean"})
    add_configs("imgui", {description = "Define method to convert omath types to imgui types", default = true, type = "boolean"})

    add_deps("cmake")
    if is_plat("windows") then
        add_deps("pkgconf")
    else
        add_deps("pkg-config")
    end

    on_load(function (package)
        if package:config("imgui") then
            package:add("deps", "imgui")
        end
    end)

    on_install("!macosx and !iphoneos and !android and !bsd", function (package)
        if package:config("imgui") then
            local imgui = package:dep("imgui")
            if imgui and not imgui:is_system() then
                local imgui_fetch = imgui:fetch()
                if imgui_fetch then
                    for _, inc in ipairs(imgui_fetch.includedirs or imgui_fetch.sysincludedirs) do
                        os.mkdir(inc)
                    end
                end
            end
        end
        io.replace("CMakeLists.txt", [[find_package(imgui CONFIG REQUIRED)]], [[include(FindPkgConfig)
pkg_search_module("imgui" REQUIRED IMPORTED_TARGET "imgui")]], {plain = true})
        io.replace("CMakeLists.txt", [[imgui::imgui]], [[PkgConfig::imgui]], {plain = true})
        if package:is_plat("wasm") then
            io.replace("CMakeLists.txt", [[target_compile_options(${PROJECT_NAME} PRIVATE -mavx2 -mfma)]], [[target_compile_options(${PROJECT_NAME} PRIVATE -msimd128 -mavx2)]], {plain = true})
        end
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
        ]]}, {configs = {languages = "c++23"}, includes = "omath/vector2.hpp"}))
    end)
