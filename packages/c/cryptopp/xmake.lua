package("cryptopp")
    set_homepage("https://cryptopp.com/")
    set_description("free C++ class library of cryptographic schemes")

    add_urls("https://github.com/weidai11/cryptopp.git")
    add_urls("https://github.com/weidai11/cryptopp/archive/refs/tags/CRYPTOPP_$(version).tar.gz", {version = function (version) return version:gsub("%.", "_") end})
    add_versions("8.9.0", "ab5174b9b5c6236588e15a1aa1aaecb6658cdbe09501c7981ac8db276a24d9ab")
    add_versions("8.7.0", "8d6a4064b8e9f34cd3e838f5a12c40067ee7b95ee37d9173ec273cb0913e7ca2")
    add_versions("8.6.0", "9304625f4767a13e0a5f26d0f019d78cf9375604a33e5391c3bf2e81399dfeb8")
    add_versions("8.5.0", "8f64cf09cf4f61d5d74bca53574b8cc9959186cc0f072a2e6597e4999d6ad5db")
    add_versions("8.4.0", "6687dfc1e33b084aeab48c35a8550b239ee5f73a099a3b6a0918d70b8a89e654")

    add_resources("8.9.0", "cryptopp_cmake", "https://github.com/abdes/cryptopp-cmake/archive/CRYPTOPP_8_9_0.tar.gz", "191d69061c56602de1610ebf03b44dcf75636006e7e60ef8105bee6472ec0caf")
    add_resources("8.7.0", "cryptopp_cmake", "https://github.com/abdes/cryptopp-cmake/archive/CRYPTOPP_8_7_0_1.tar.gz", "49800456bec6432eff4a798d37f6c7760b887adc9f8928e66f44bcb8bf81f157")
    add_resources("8.6.0", "cryptopp_cmake", "https://github.com/noloader/cryptopp-cmake/archive/CRYPTOPP_8_6_0.tar.gz", "970b20d55dbf9d6335485e72c9f8967d878bf64bbd3de6aa28436beb6799c493")
    add_resources("8.5.0", "cryptopp_cmake", "https://github.com/noloader/cryptopp-cmake/archive/CRYPTOPP_8_5_0.tar.gz", "10685209405e676993873fcf638ade5f8f99d7949afa6b2045289ce9cc6d90ac")
    add_resources("8.4.0", "cryptopp_cmake", "https://github.com/noloader/cryptopp-cmake/archive/CRYPTOPP_8_4_0.tar.gz", "b850070141f6724fce640e4e2cfde433ec5b2d99d4386d29ba9255167bc4b4f0")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::crypto++")
    elseif is_plat("linux") then
        add_extsources("pacman::crypto++", "apt::libcrypto++-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::cryptopp")
    end

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_install(function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "CRYPTOPP_IMPORTS")
        end

        local cryptopp_cmake = package:resourcedir("cryptopp_cmake")
        os.cp(path.join(cryptopp_cmake, "*", "CMakeLists.txt"), ".")
        if package:version() and package:version():le("8.6") then
            os.cp(path.join(cryptopp_cmake, "*", "cryptopp-config.cmake"), ".")
        else
            os.cp(path.join(cryptopp_cmake, "*", "CMakePresets.json"), ".")
            os.cp(path.join(cryptopp_cmake, "*", "cmake"), ".")
            os.cp(path.join(cryptopp_cmake, "*", "cryptopp"), ".")
            os.cp(path.join(cryptopp_cmake, "*", "test"), ".")
        end
        -- fix unresolved external symbol PadLastBlock
        -- @see https://github.com/weidai11/cryptopp/issues/358
        io.replace("iterhash.h", "CRYPTOPP_NO_VTABLE", "CRYPTOPP_DLL CRYPTOPP_NO_VTABLE", {plain = true})

        if os.isfile("cryptopp/CMakeLists.txt") then
            io.replace("cryptopp/CMakeLists.txt", "set(CMAKE_CXX_VISIBILITY_PRESET hidden)", "", {plain = true})
            io.replace("cryptopp/CMakeLists.txt", "set(CMAKE_VISIBILITY_INLINES_HIDDEN YES)", "", {plain = true})
            io.replace("cryptopp/CMakeLists.txt", "set(CMAKE_POSITION_INDEPENDENT_CODE 1)", "", {plain = true})
            io.replace("cryptopp/CMakeLists.txt", [[target_compile_definitions(cryptopp PRIVATE "CRYPTOPP_EXPORTS")]], "", {plain = true})
            io.replace("cryptopp/CMakeLists.txt",
                "set(BUILD_SHARED_LIBS ${CRYPTOPP_BUILD_SHARED})",
                format("set(CRYPTOPP_BUILD_SHARED %s)", package:config("shared") and "ON" or "OFF"), {plain = true})
        end

        local configs = {
            -- Disable auto fetch source code
            "-DCRYPTOPP_SOURCES=" .. path.unix(os.curdir()),
            "-DBUILD_TESTING=OFF",
            "-DCRYPTOPP_BUILD_TESTING=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DBUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))

        if package:is_plat("windows") and package:is_arch("arm", "arm64") then
            table.insert(configs, "-DDISABLE_ASM=ON")
            table.insert(configs, "-DDISABLE_SSSE3=ON")
            table.insert(configs, "-DDISABLE_SSE4=ON")
            table.insert(configs, "-DDISABLE_AESNI=ON")
            table.insert(configs, "-DDISABLE_CLMUL=ON")
            table.insert(configs, "-DDISABLE_SHA=ON")
            table.insert(configs, "-DDISABLE_AVX=ON")
            table.insert(configs, "-DDISABLE_AVX2=ON")
        end

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
