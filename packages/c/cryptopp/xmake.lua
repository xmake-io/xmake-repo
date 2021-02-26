package("cryptopp")

    set_homepage("https://cryptopp.com/")
    set_description("free C++ class library of cryptographic schemes")

    add_urls("https://github.com/weidai11/cryptopp/archive/CRYPTOPP_$(version).tar.gz", {version = function (version) return version:gsub("%.", "_") end})
    add_versions("8.4.0", "6687dfc1e33b084aeab48c35a8550b239ee5f73a099a3b6a0918d70b8a89e654")

    add_resources("8.4.0", "cryptopp_cmake", "https://github.com/noloader/cryptopp-cmake/archive/CRYPTOPP_8_4_0.tar.gz", "b850070141f6724fce640e4e2cfde433ec5b2d99d4386d29ba9255167bc4b4f0")

    add_deps("cmake")

    on_install("windows", "macosx", "linux", "bsd", "iphoneos", "android", function (package)
        local cryptopp_cmake = package:resourcedir("cryptopp_cmake")
        os.cp(path.join(cryptopp_cmake, "*", "CMakeLists.txt"), ".")
        os.cp(path.join(cryptopp_cmake, "*", "cryptopp-config.cmake"), ".")
        -- fix unresolved external symbol PadLastBlock
        -- @see https://github.com/weidai11/cryptopp/issues/358
        io.replace("iterhash.h", "CRYPTOPP_NO_VTABLE", "CRYPTOPP_DLL CRYPTOPP_NO_VTABLE")
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DBUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DBUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        local cxflags
        if package:is_plat("windows") and package:config("shared") then
            cxflags = "-DCRYPTOPP_EXPORTS"
        end
        import("package.tools.cmake").install(package, configs, {cxflags = cxflags})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cryptopp/cryptlib.h>
            #include <cryptopp/aes.h>
            #include <cryptopp/modes.h>
            using namespace CryptoPP;
            void test() {
                unsigned char key[]	= {0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,	0x01,0x02, 0x03,0x04,0x05,0x06,0x07,0x08};
                unsigned char iv[]	= {0x01,0x02,0x03,0x03,0x03,0x03,0x03,0x03,	0x03,0x03, 0x01,0x02,0x03,0x03,0x03,0x03};
	            CTR_Mode<AES>::Encryption Encryptor2(key, 16, iv);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
