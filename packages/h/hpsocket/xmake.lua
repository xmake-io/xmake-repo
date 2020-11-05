package("hpsocket")
    set_homepage("https://github.com/ldcsaa/HP-Socket")
    set_description("High Performance Network Framework")
    add_urls("https://github.com/ldcsaa/HP-Socket/archive/$(version).tar.gz",
             "https://github.com/ldcsaa/HP-Socket.git")

    add_versions("v5.7.2", "4397375000ec261265542498f6c5675d71cec9582319a9083e0f77ac41deac5a")

    if is_plat("windows") then
        add_syslinks("crypt32","ws2_32","kernel32")
    elseif is_plat("linux") then
        add_syslinks("rt","dl","pthread")
    elseif is_plat("linux") then
        add_syslinks("dl")
    end

    on_load(function (package)
        if package:is_plat("windows") then
            package:add("defines", "HPSOCKET_STATIC_LIB")
        end
    end)

    on_install("windows", function (package)
        
        io.writefile("stdafx.h", [[
        #pragma once
        #define _DETECT_MEMORY_LEAK
        #include "Windows/Common/Src/GeneralHelper.h"
        ]])
        io.writefile("stdafx.cpp", [[
            #include "stdafx.h"
        ]])        
        io.writefile("xmake.lua", [[
        add_rules("mode.debug", "mode.release")
        target("hpsocket")
            set_kind("static")
            add_includedirs("/")
            set_pcxxheader("stdafx.h")
            add_defines("HPSOCKET_STATIC_LIB")
            
            if is_mode("debug") then 
                add_cxxflags("/MTd")
                set_symbols("debug")
            else 
                add_cxxflags("/MT")
            end

            add_files(
            "Windows/Common/Src/zlib/*.c",
            "Windows/Common/Src/http/http_parser.c",
            "Windows/Common/Src/kcp/ikcp.c",   
            "Windows/Common/Src/*.cpp",       
            "Windows/Src/*.cpp|HPSocket4C-SSL.cpp|HPSocket4C.cpp",
            "stdafx.cpp")

            local use_jemalloc = true
            local vs    = get_config("vs")
            local vs_ver= "10.0"
            local arch  = "x64"

            if is_arch("x86") then 
                arch = "x86"
            end

            if vs == "2015"     then  vs_ver = "14.0"
            elseif vs == "2017" then  vs_ver = "15.0"
            elseif vs == "2019" then  vs_ver = "16.0"
            else 
                use_jemalloc = false
            end

            local openssl_inc_dir = "Windows/Common/Lib/openssl/".. vs_ver .."/"..arch.."/include"
            local openssl_lib_dir = "Windows/Common/Lib/openssl/".. vs_ver .."/"..arch.."/lib" 

            local jemalloc_lib_dir = "Windows/Common/Lib/jemalloc/".. vs_ver .."/"..arch.."/lib" 

            add_includedirs(openssl_inc_dir)   
            add_files(openssl_lib_dir .. "/libssl.lib")
            add_files(openssl_lib_dir .. "/libcrypto.lib")

            if use_jemalloc then
                add_files(jemalloc_lib_dir.. "/jemalloc.lib")
            end
            
            add_headerfiles("Windows/Include/HPSocket/HPSocket.h",
                            "Windows/Include/HPSocket/HPSocket-SSL.h",
                            "Windows/Include/HPSocket/HPTypeDef.h",
                            "Windows/Include/HPSocket/SocketInterface.h")                
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_install("linux", "android",function (package)
        io.writefile("xmake.lua",[[
        target("hpsocket")
            set_kind("static")

            add_files(
                "Linux/src/common/crypto/Crypto.cpp",
                "Linux/src/common/http/http_parser.c",
                "Linux/src/common/kcp/ikcp.c",
                "Linux/src/common/*.cpp",
                "Linux/src/*.cpp|HPSocket4C-SSL.cpp|HPSocket4C.cpp"
            )

            local include_dir
            local link_dir

            if is_plat("android") then 
                include_dir = "Linux/dependent/android-ndk/$(arch)/include"
                link_dir    = "Linux/dependent/android-ndk/$(arch)/lib"
            else 
                local arch  = "x86"
                if is_arch("x86_64") then 
                    arch = "x64"
                end    
                include_dir = "Linux/dependent/".. arch .."/include"
                link_dir    = "Linux/dependent/".. arch .. "/lib"         
            end

            add_includedirs(include_dir)   
            add_linkdirs(link_dir)
            add_files(link_dir .. "/libssl.a")
            add_files(link_dir .. "/libcrypto.a")

            if is_plat("android") then
                add_files(link_dir .. "/libiconv.a")
                add_files(link_dir .. "/libcharset.a")    
            else 
                add_files(link_dir .. "/libz.a")
                add_files(link_dir .. "/libjemalloc_pic.a")
            end  

            add_headerfiles("Linux/include/hpsocket/HPSocket.h", 
                            "Linux/include/hpsocket/HPSocket-SSL.h",
                            "Linux/include/hpsocket/HPTypeDef.h",
                            "Linux/include/hpsocket/SocketInterface.h",
                            "Linux/include/hpsocket/(common/*.h)")                 
          
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            #include "HPSocket.h"
            static void test() {
                std::cout << HP_GetHPSocketVersion() << "\\n";
            }
        ]]}, {configs = {languages = "c++11"}, includes = "HPSocket.h", defines="HPSOCKET_STATIC_LIB"}))        
    end)    
