package("cppcodec")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/tplgy/cppcodec")
    set_description("Header-only C++11 library to encode/decode base64, base64url, base32, base32hex and hex (a.k.a. base16) as specified in RFC 4648, plus Crockford's base32. MIT licensed with consistent, flexible API.")
    set_license("MIT")

    add_urls("https://github.com/tplgy/cppcodec.git")

    add_versions("2022.09.07", "8019b8b580f8573c33c50372baec7039dfe5a8ce")

    on_install(function (package)
        os.vcp("cppcodec", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cppcodec/base64_rfc4648.hpp>
            using base64 = cppcodec::base64_rfc4648;
            void test() {
                std::vector<uint8_t> decoded = base64::decode("YW55IGNhcm5hbCBwbGVhc3VyZQ==");
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
