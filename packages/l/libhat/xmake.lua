package("libhat")
    set_homepage("https://github.com/BasedInc/libhat")
    set_description("A high-performance, modern, C++20 library designed around game hacking")
    set_license("MIT")

    add_urls("https://github.com/BasedInc/libhat/archive/refs/tags/$(version).tar.gz", {alias = "release"})
    add_urls("https://github.com/BasedInc/libhat.git", {alias = "github"})

    add_versions("release:v0.5.0", "d68a1913bfed2eaa087ea2d8c19ac82c9301839df1bc1beea97b22b532e48adc")

    add_configs("sse",          {description = "Enable SSE 4.1 scanning", default = false, type = "boolean"})
    add_configs("avx",          {description = "Enable AVX512 scanning", default = false, type = "boolean"})
    add_configs("module",       {description = "Create target for the module interface", default = false, type = "boolean"})
    add_configs("std_module",   {description = "Compile the module target using the std module", default = false, type = "boolean"})
    add_configs("hint",         {description = "Enables support for the x86_64 scan hint, requires a small (less than 1KB) data table", default = false, type = "boolean"})

    add_deps("cmake")

    on_check("windows", function (package)
        import("core.tool.toolchain")
        local msvc = toolchain.load("msvc", {plat = package:plat(), arch = package:arch()})
        local vs = msvc:config("vs")
        if vs and tonumber(vs) < 2022 then
            raise("package(libhat): MSVC 2019 and earlier are not supported.")
        end
    end)

    on_check("android", function (package)
        local ndk = package:toolchain("ndk"):config("ndkver")
        assert(ndk and tonumber(ndk) > 22, "package(glosshook) require ndk version > 22")
    end)

    on_install("!bsd and !wasm", function (package)
        if os.exists("include/libhat/compressed_pair.hpp") then
            io.replace("include/libhat/compressed_pair.hpp", [[#include "defines.hpp"]], [[#include "defines.hpp"
#include <cstddef>]], {plain = true})
        end
        io.replace("CMakeLists.txt", "/clang:-Werror", "", {plain = true})
        io.replace("CMakeLists.txt", "-Werror", "", {plain = true})
        local configs = {"-DLIBHAT_TESTING=OFF", "-DLIBHAT_TESTING_ASAN=OFF", "-DLIBHAT_TESTING_SDE=OFF", "-DLIBHAT_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DLIBHAT_SHARED_C_LIB=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLIBHAT_STATIC_C_LIB=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DLIBHAT_DISABLE_SSE=" .. (package:config("sse") and "OFF" or "ON"))
        table.insert(configs, "-DLIBHAT_DISABLE_AVX512=" .. (package:config("avx") and "OFF" or "ON"))
        table.insert(configs, "-DLIBHAT_MODULE_TARGET=" .. (package:config("module") and "ON" or "OFF"))
        table.insert(configs, "-DLIBHAT_USE_STD_MODULE=" .. (package:config("std_module") and "ON" or "OFF"))
        table.insert(configs, "-DLIBHAT_HINT_X86_64=" .. (package:config("hint") and "ON" or "OFF"))
        io.replace("CMakeLists.txt", [[install(TARGETS libhat]], [[install(TARGETS libhat_c
        EXPORT libhat_c-targets RUNTIME DESTINATION "bin" ARCHIVE DESTINATION "lib" LIBRARY DESTINATION "lib")
        install(TARGETS libhat]], {plain = true})
        local CMakeLists_content = io.readfile("CMakeLists.txt")
        io.writefile("CMakeLists.txt", CMakeLists_content .. [[
            if(LIBHAT_MODULE_TARGET AND TARGET libhat_module)
                install(TARGETS libhat_module
                    EXPORT libhat_module-targets FILE_SET CXX_MODULES DESTINATION include RUNTIME DESTINATION "bin" ARCHIVE DESTINATION "lib" LIBRARY DESTINATION "lib")
            endif()
        ]])
        local opt = {}
        if package:config("module") and package:has_tool("cxx", "cl") then
            opt.cxflags = {"/EHsc", "/experimental:module"}
        end
        import("package.tools.cmake").install(package, configs, opt)
        os.cp("include", package:installdir())
    end)
    

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <libhat.hpp>
            void test() {
                auto pattern = hat::compile_signature<"48 8D 05 ? ? ? ? E8">();
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
