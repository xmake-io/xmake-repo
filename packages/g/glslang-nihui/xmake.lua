package("glslang-nihui")
    set_homepage("https://github.com/nihui/glslang/")
    set_description("nihui's fork of KhronosGroup/glslang for C++14 compatibility. This package is designed for Tencent/ncnn.")
    set_license("Apache-2.0")

    add_urls("https://github.com/nihui/glslang.git")

    add_versions("20250916", "8cd77a808d0bffa442ae9462d5e3a8141892ba5a")
    add_versions("20250503", "a9ac7d5f307e5db5b8c4fbf904bdba8fca6283bc")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        package:add("links", "glslang", "glslang-default-resource-limits")
    end)

    on_install(function (package)
        -- glslang will add a debug lib postfix for win32 platform, disable this to fix compilation issues under windows
        io.replace("CMakeLists.txt", 'set(CMAKE_DEBUG_POSTFIX "d")', [[
            message(WARNING "Disabled CMake Debug Postfix for xmake package generation")
        ]], {plain = true})
        io.replace("CMakeLists.txt", "set(CMAKE_CXX_STANDARD 17)", "set(CMAKE_CXX_STANDARD 14)", {plain = true})
        io.replace("glslang/MachineIndependent/Intermediate.cpp", "#include <cfloat>", "#include <cfloat>\n#include <limits>", {plain = true})

        if package:is_plat("wasm") then
            -- wasm-ld doesn't support --no-undefined
            io.replace("CMakeLists.txt", [[add_link_options("-Wl,--no-undefined")]], "", {plain = true})
        end

        local configs = {
            "-DGLSLANG_TESTS=OFF",
            "-DBUILD_EXTERNAL=OFF",
            "-DENABLE_PCH=OFF",
            "-DENABLE_GLSLANG_BINARIES=OFF",
            "-DENABLE_SPVREMAPPER=OFF",
            "-DENABLE_OPT=OFF",
            "-DENABLE_HLSL=OFF",
            "-DENABLE_EXCEPTIONS=OFF",
            "-DENABLE_RTTI=OFF"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        import("package.tools.cmake").install(package, configs)

        os.cp("glslang/MachineIndependent/**.h", package:installdir("include", "glslang", "MachineIndependent"))
        os.cp("glslang/Include/**.h", package:installdir("include", "glslang", "Include"))
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("ShInitialize", {configs = {languages = "c++14"}, includes = "glslang/Public/ShaderLang.h"}))
    end)
