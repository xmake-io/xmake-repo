add_rules("mode.debug", "mode.release")
target("hpsocket")
    set_kind("static")
    if is_plat("windows") then
        add_includedirs("/")
        set_pcxxheader("stdafx.h")
        add_defines("HPSOCKET_STATIC_LIB")

        add_files("stdafx.cpp")
        add_files("Windows/Common/Src/zlib/*.c")
        add_files("Windows/Common/Src/http/http_parser.c")
        add_files("Windows/Common/Src/kcp/ikcp.c")
        add_files("Windows/Common/Src/*.cpp")
        add_files("Windows/Src/*.cpp|HPSocket4C-SSL.cpp|HPSocket4C.cpp")

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

        local openssl_inc_dir = "Windows/Common/Lib/openssl/" .. vs_ver .. "/" .. arch .. "/include"
        local openssl_lib_dir = "Windows/Common/Lib/openssl/" .. vs_ver .. "/" .. arch .. "/lib"
        add_includedirs(openssl_inc_dir)
        add_linkdirs(openssl_lib_dir)
        add_links("libssl", "libcrypto", "crypt32")
        
        add_headerfiles("Windows/Include/HPSocket/HPSocket.h")
        add_headerfiles("Windows/Include/HPSocket/HPSocket-SSL.h")
        add_headerfiles("Windows/Include/HPSocket/HPTypeDef.h")
        add_headerfiles("Windows/Include/HPSocket/SocketInterface.h")
    end

    if is_plat("linux", "android") then
        add_cxxflags("-fPIC")
        add_files("Linux/src/common/crypto/Crypto.cpp")
        add_files("Linux/src/common/http/http_parser.c")
        add_files("Linux/src/common/kcp/ikcp.c")
        add_files("Linux/src/common/*.cpp")
        add_files("Linux/src/*.cpp|HPSocket4C-SSL.cpp|HPSocket4C.cpp")

        local include_dir
        local link_dir
        if is_plat("android") then
            include_dir = "Linux/dependent/android-ndk/$(arch)/include"
            link_dir = "Linux/dependent/android-ndk/$(arch)/lib"
        else 
            local arch = "x86"
            if is_arch("x86_64") then
                arch = "x64"
            end
            include_dir = "Linux/dependent/" .. arch .. "/include"
            link_dir = "Linux/dependent/" .. arch .. "/lib"
        end
        add_includedirs(include_dir)
        add_linkdirs(link_dir)
        add_links("ssl", "crypto")
        if is_plat("android") then
            add_links("iconv", "charset")
        else
            add_links("z", "jemalloc_pic")
        end

        add_headerfiles("Linux/include/hpsocket/HPSocket.h") 
        add_headerfiles("Linux/include/hpsocket/HPSocket-SSL.h")
        add_headerfiles("Linux/include/hpsocket/HPTypeDef.h")
        add_headerfiles("Linux/include/hpsocket/SocketInterface.h")
        add_headerfiles("Linux/include/hpsocket/(common/*.h)")
    end