package("slikenet")
    set_homepage("https://www.slikenet.com/")
    set_description("SLikeNet™ is an Open Source/Free Software cross-platform network engine written in C++ and specifially designed for games (and applications which have comparable requirements on a network engine like games) building upon the discontinued RakNet network engine which had more than 13 years of active development.")
    set_license("MIT")

    add_urls("https://github.com/SLikeSoft/SLikeNet.git")
    add_versions("2021.07.01", "d5f775d789563a2d505e2afbf99a550d990bb49e")

    add_patches("2021.07.01", "patches/2021.07.01/fix-emscripten.patch", "c4d8ffbbdb5fe1ca95f6fd7dbdafb83976fa5de9435e80e6aab5f8c34ae74d62")
    add_patches("2021.07.01", "patches/2021.07.01/fix-install.patch", "7f1307651bbf7fdff4cedf1b0301521275d83a060361ffc896065254c9908953")
    add_patches("2021.07.01", "patches/2021.07.01/fix-mingw.patch", "904ee48e53f31cf0a4cd40cef3db50ff64d641e40089816d4f0923b10ddcff81")
    add_patches("2021.07.01", "patches/2021.07.01/fix-dllimport.patch", "8322c19f9a3f756a3937ee7009a4e89bb56cba31ff590eb108b9a0582daef7d8")

    add_deps("cmake")
    add_deps("openssl3")

    if is_plat("windows", "mingw") then
        add_syslinks("iphlpapi", "ws2_32", "winmm")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_load("windows", "mingw", function (package)
        if package:config("shared") then
            package:add("defines", "_RAKNET_DLL_IMPORT")
        end
    end)

    on_check("android", function (package)
        local ndk_sdkver = package:toolchain("ndk"):config("ndk_sdkver")
        if ndk_sdkver and tonumber(ndk_sdkver) < 24 then
            raise("package(slikenet) require ndk api >= 24")
        end
    end)

    on_install(function (package)
        io.replace("CMakeLists.txt", "ws2_32.lib", "iphlpapi ws2_32 winmm", {plain = true})
        io.replace("Source/include/slikenet/WindowsIncludes.h", [[#include <IPHlpApi.h>]], [[#include <iphlpapi.h>]], {plain = true})
        io.replace("Source/include/slikenet/WindowsIncludes.h", [[#pragma comment(lib, "IPHLPAPI.lib")]], [[]], {plain = true})
        io.replace("Source/src/GetTime.cpp", [[#pragma comment(lib, "Winmm.lib")]], [[]], {plain = true})
        if package:is_plat("linux", "cross") and package:is_arch("arm.*") then
            io.replace("Source/src/FileList.cpp", "#include <sys/io.h>", "", {plain = true})
        elseif package:is_plat("android") then
            io.replace("Source/src/FileList.cpp", "#include <asm/io.h>", "#include <ifaddrs.h>", {plain = true})
        end
        os.rmdir("Source/src/crypto")
        os.rmdir("Source/include/slikenet/crypto")
        local configs = {"-DSLIKENET_ENABLE_SAMPLES=OFF"}
        table.insert(configs, "-DSLIKENET_ENABLE_DLL=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSLIKENET_ENABLE_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <slikenet/TCPInterface.h>
            using namespace SLNet;
            void test() {
                TCPInterface *g = TCPInterface::GetInstance();
                g->Stop();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
