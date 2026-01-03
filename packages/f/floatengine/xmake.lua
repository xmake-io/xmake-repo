package("floatengine")
    set_homepage("https://github.com/Fls-Float/FloatEngine")
    set_description("A high-performance, cross-platform C++ game engine.")
    set_license("MIT")

    add_urls("https://github.com/fls-float/FloatEngine.git")

    add_versions("2025.12.20", "d3754c2b8235fe1920aea65cfd7cd9247c758408")

    add_patches("2025.12.20", "patches/2025.12.20/cleanup.patch", "9cc02d875d308eccbf53ffe0c04fff4893e8221b396bcb361a378a869dae29ce")
    add_patches("2025.12.20", "patches/2025.12.20/fix-template.patch", "66450b0e49549d602e7436d234b46af83e779778398b4d2bb4fc9b5376143388")

    add_deps("minizip-ng", {configs = {bzip2 = true}})
    add_deps("lua", "libcurl", "slikenet", "nlohmann_json", "nativefiledialog-extended", "fls-float-raylib", "sol2", "imgui")

    if is_plat("windows", "mingw") then
        add_syslinks("user32", "kernel32", "ws2_32", "iphlpapi")
    end

    on_install("windows", "mingw", function (package)
        io.replace("FloatEngine/F_Resource.cpp", [[#include "minizip-ng/]], [[#include "minizip/]], {plain = true})
        io.replace("FloatEngine/F_Network.cpp", [[#include "F_NetWork.h"]], [[#include "F_Network.h"]], {plain = true})
        io.replace("FloatEngine/F_Network.cpp", [[#include "slikenet/Peer.h"]], [[#include "slikenet/peer.h"]], {plain = true})
        io.replace("FloatEngine/F_Network.cpp", [[#include "slikenet/Types.h"]], [[#include "slikenet/types.h"]], {plain = true})
        io.replace("FloatEngine/winfuns.h", [[#ifndef WINFUNS_HAVE_WSADATA]],
                                            [[#ifndef WINFUNS_HAVE_WSADATA
                                            #ifndef WSADESCRIPTION_LEN
                                            #define WSADESCRIPTION_LEN      256
                                            #endif
                                            #ifndef WSASYS_STATUS_LEN
                                            #define WSASYS_STATUS_LEN       128
                                            #endif
                                            #include <sal.h>]], {plain = true})
        io.replace("FloatEngine/FMath.cpp", "#include <numeric>", "#include <numeric>\n#include <cfloat>", {plain = true})
        io.replace("FloatEngine/F_Network.h", "#include <memory>", "#include <memory>\n#include <cstdint>", {plain = true})
        io.replace("FloatEngine/FloatApi.h", "struct ImGuiInputTextCallbackData;", "#include <cfloat>\nstruct ImGuiInputTextCallbackData;", {plain = true})
        io.writefile("xmake.lua", [[
            set_languages("c11", "c++17")
            add_rules("mode.release", "mode.debug")
            add_requires("minizip-ng", {configs = {bzip2 = true}})
            add_requires("lua", "libcurl", "slikenet", "nlohmann_json", "nativefiledialog-extended", "fls-float-raylib", "sol2", "imgui")
            add_packages("minizip-ng", "lua", "libcurl", "slikenet", "nlohmann_json", "nativefiledialog-extended", "fls-float-raylib", "sol2", "imgui")
            set_encodings("utf-8")
            target("floatengine")
                set_kind("$(kind)")
                add_files("FloatEngine/*.cpp",
                          "FloatEngine/*.c")
                add_headerfiles("(FloatEngine/*.h)",
                                "(FloatEngine/*.hpp)")
                add_includedirs("FloatEngine",
                                "FloatEngine/gui/include")
                add_syslinks("user32", "kernel32", "ws2_32", "iphlpapi")
                add_defines("WIN32_LEAN_AND_MEAN", "NOMINMAX")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                Sprite sprite = Sprite();
                size_t w = sprite.FrameCount();
            }
        ]]}, {configs = {languages = "c++17"}, includes = "FloatEngine/Sprite.h"}))
    end)
