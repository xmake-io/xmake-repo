package("hpsocket")
    set_homepage("https://github.com/ldcsaa/HP-Socket")
    set_description("High Performance Network Framework")
    add_urls("https://github.com/ldcsaa/HP-Socket/archive/$(version).tar.gz",
             "https://github.com/ldcsaa/HP-Socket.git")

    add_versions("v5.7.2", "4397375000ec261265542498f6c5675d71cec9582319a9083e0f77ac41deac5a")

    if is_plat("windows") then
        add_syslinks("crypt32", "ws2_32", "kernel32")
        add_links("hpsocket", "libssl", "libcrypto")
    elseif is_plat("linux") then
        add_syslinks("rt", "dl", "pthread")
        add_links("hpsocket", "ssl", "crypto", "z", "jemalloc_pic")
    elseif is_plat("android") then
        add_syslinks("dl", "z")
        add_links("hpsocket", "ssl", "crypto", "iconv", "charset")
    end

    on_load(function (package)
        if package:is_plat("windows") then
            package:add("defines", "HPSOCKET_STATIC_LIB")
        end
    end)

    on_install("windows", "linux", "android", function (package)
        if package:is_plat("windows") then
            io.writefile("stdafx.h", [[
            #pragma once
            #define _DETECT_MEMORY_LEAK
            #include "Windows/Common/Src/GeneralHelper.h"
            ]])
            io.writefile("stdafx.cpp", [[
                #include "stdafx.h"
            ]])
        end
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)

        if package:is_plat("windows") then
            local vs = get_config("vs")
            local vs_ver = "10.0"
            local arch = "x64"
            if is_arch("x86") then
                arch = "x86"
            end

            if vs == "2015" then
                vs_ver = "14.0"
            elseif vs == "2017" then
                vs_ver = "15.0"
            elseif vs == "2019" then
                vs_ver = "16.0"
            end
            os.cp("Windows/Common/Lib/openssl/" .. vs_ver .. "/" .. arch .. "/lib" .. "/*.lib", package:installdir("lib"))
        elseif package:is_plat("linux") then
            local arch = "x86"
            if is_arch("x86_64") then 
                arch = "x64"
            end
            os.cp("Linux/dependent/" .. arch .. "/lib" .. "/*.a", package:installdir("lib"))
        elseif package:is_plat("android") then
            os.cp("Linux/dependent/android-ndk/$(arch)/lib/*.a", package:installdir("lib"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            #include "HPSocket.h"
            static void test() {
                std::cout << HP_GetHPSocketVersion() << "\n";
            }
        ]]}, {configs = {languages = "c++11"}, includes = "HPSocket.h", defines = "HPSOCKET_STATIC_LIB"}))
    end)
