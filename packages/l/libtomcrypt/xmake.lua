package("libtomcrypt")
    set_homepage("https://www.libtom.net")
    set_description("LibTomCrypt is a fairly comprehensive, modular and portable cryptographic toolkit that provides developers with a vast array of well known published block ciphers, one-way hash functions, chaining modes, pseudo-random number generators, public key cryptography and a plethora of other routines.")
    set_license("Unlicense")

    add_urls("https://github.com/libtom/libtomcrypt.git")

    add_versions("2024.06.26", "2302a3a89752b317d59e9cdb67d2d4eb9b53be8e")

    add_deps("libtommath", "cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") and package:config("shared") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <libtomcrypt/tomcrypt.h>
            void test() {
                unsigned char input[] = "hello";
                unsigned long input_len = 5;
                char out[256];
                unsigned long out_len;
                base64_encode(input, input_len, out, &out_len);
            }
        ]]}, {configs = {languages = "cxx11"}}))
    end)
