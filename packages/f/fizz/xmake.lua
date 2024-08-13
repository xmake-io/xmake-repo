package("fizz")
    set_homepage("https://github.com/facebookincubator/fizz")
    set_description("C++14 implementation of the TLS-1.3 standard ")
    set_license("BSD")

    add_urls("https://github.com/facebookincubator/fizz/releases/download/v$(version).00/fizz-v$(version).00.zip",
             "https://github.com/facebookincubator/fizz.git")
    add_versions("2024.02.26", "fa389dca0c49e14e83e089f07f896bf616757b3c70723ddfac7be2e3fd1f312f")
    add_versions("2024.03.04", "1a7da63780ae1bbcc00f9a317911e814a49f84e4d9009254328ea0a5e121817f")
    add_versions("2024.03.11", "96693000954ed352eae4df3113ef6b1c8b2237100a83b8987dcf067ecfe8c2e8")
    add_versions("2024.03.18", "f46799dda118ec5a35cf7533e00daf25e7b2d7c58f00b80ba6c0388b19190c6f")
    add_versions("2024.03.25", "bcf9c551719bc86318a77e2b13769d52679642b98728e645900485d7a90c0f8b")
    add_versions("2024.04.01", "caf2cf1ba8f6db66abbadf382fb3e0667888567c4ac0d8f74ec92e1fb27c3727")
    add_versions("2024.06.10", "dabc77e2238383fb37c19327af8ab864ba030d32e98f49b23008075a7afb6e19")
    add_versions("2024.06.17", "46e9d1b782a51b2c063390dc1161f26f2c77ef7a94ff8ccc4bdc272697cad8bb")
    add_versions("2024.06.24", "b5fd5fb3fe1cf20519ea91d6a0127505596f8c74c82cde9d54ea6ae92df86a50")
    add_versions("2024.07.01", "002bca2765cb0889ec535eeb1950acf93af57638a2da9b2deacc522113625fcc")
    add_versions("2024.07.08", "dd80231fb79760ef0b15394364ddbe35d4da82a7e07238dbaaf2f98f267d3938")
    add_versions("2024.07.15", "44da982621aa91f15f5b2ec7a27510aab4650383b3a135372586501f3f44fc6c")

    add_deps("cmake", "folly", "libsodium", "liboqs")

    on_install("linux", "macosx", function (package)
        os.cd("fizz")
        local configs = {"-DBUILD_TESTS=OFF",
                         "-DBUILD_EXAMPLES=OFF",
                         "-DCMAKE_CXX_STANDARD=17",
                         "-DFIZZ_HAVE_OQS=TRUE"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "fizz/experimental/crypto/exchange/OQSKeyExchange.h"
            void test() {
                auto clientKex = fizz::OQSClientKeyExchange(OQS_KEM_alg_kyber_768);
                auto serverKex = fizz::OQSServerKeyExchange(OQS_KEM_alg_kyber_768);
                clientKex.generateKeyPair();
                serverKex.generateKeyPair();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
