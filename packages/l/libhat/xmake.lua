package("libhat")
    set_homepage("https://github.com/BasedInc/libhat")
    set_description("A high-performance, modern, C++20 library designed around game hacking")
    set_license("MIT")

    add_urls("https://github.com/BasedInc/libhat/archive/refs/tags/$(version).tar.gz",
             "https://github.com/BasedInc/libhat.git")

    add_versions("v0.9.0", "b1e9e16e804d9f9bec7ccc4df4b8a1cdd281b6ec0c1377244ab28a7944a3e13a")
    add_versions("v0.7.0", "09c080be938d6e8901f1af8da74a66dc9d424393e071e1ada5ae13d86c2c9c9b")
    add_versions("v0.6.0", "9e25b898277d0bc248e1860ef11acd2dcd860d7fcdadb04d038588c60a850a4f")
    add_versions("v0.5.0", "d68a1913bfed2eaa087ea2d8c19ac82c9301839df1bc1beea97b22b532e48adc")

    add_configs("sse", {description = "Enable SSE 4.1 scanning", default = false, type = "boolean"})
    add_configs("avx", {description = "Enable AVX512 scanning", default = false, type = "boolean"})
    add_configs("hint", {description = "Enables support for the x86_64 scan hint, requires a small (less than 1KB) data table", default = false, type = "boolean"})

    if is_plat("macosx") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")

    on_check("windows", function (package)
        local msvc = package:toolchain("msvc")
        local vs = msvc:config("vs")
        if vs and tonumber(vs) < 2022 then
            raise("package(libhat): MSVC 2019 and earlier are not supported.")
        end
    end)

    on_check("android", function (package)
        local ndk = package:toolchain("ndk"):config("ndkver")
        assert(ndk and tonumber(ndk) > 22, "package(libhat) require ndk version > 22")
    end)

    on_install("!bsd and !wasm", function (package)
        if os.exists("include/libhat/compressed_pair.hpp") then
            io.replace("include/libhat/compressed_pair.hpp", [[#include "defines.hpp"]], [[#include "defines.hpp"
#include <cstddef>]], {plain = true})
        end
        if os.exists("include/libhat/strconv.hpp") then
            io.replace("include/libhat/strconv.hpp", [[#include "result.hpp"]], [[#include "result.hpp"
#include <cstdint>]], {plain = true})
        end
        io.replace("CMakeLists.txt", "/clang:-Werror", "", {plain = true})
        io.replace("CMakeLists.txt", "-Werror", "", {plain = true})
        local configs = {"-DLIBHAT_TESTING=OFF", "-DLIBHAT_TESTING_ASAN=OFF", "-DLIBHAT_TESTING_SDE=OFF", "-DLIBHAT_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DLIBHAT_SHARED_C_LIB=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLIBHAT_STATIC_C_LIB=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DLIBHAT_DISABLE_SSE=" .. (package:config("sse") and "OFF" or "ON"))
        table.insert(configs, "-DLIBHAT_DISABLE_AVX512=" .. (package:config("avx") and "OFF" or "ON"))
        table.insert(configs, "-DLIBHAT_HINT_X86_64=" .. (package:config("hint") and "ON" or "OFF"))
        io.replace("CMakeLists.txt", [[install(TARGETS libhat]], [[install(TARGETS libhat_c
        EXPORT libhat_c-targets RUNTIME DESTINATION "bin" ARCHIVE DESTINATION "lib" LIBRARY DESTINATION "lib")
        install(TARGETS libhat]], {plain = true})
        import("package.tools.cmake").install(package, configs)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <libhat/signature.hpp>
            void test() {
                auto sig = hat::parse_signature("01 02 03 04 05 06 07 08 09").value();
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
