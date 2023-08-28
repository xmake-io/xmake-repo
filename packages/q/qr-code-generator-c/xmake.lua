package("qr-code-generator-c")
    set_homepage("https://www.nayuki.io/page/qr-code-generator-library")
    set_description("High-quality QR Code generator library in Java, TypeScript/JavaScript, Python, Rust, C++, C.")

    add_urls("https://github.com/nayuki/QR-Code-generator/archive/refs/tags/$(version).tar.gz",
             "https://github.com/nayuki/QR-Code-generator.git")

    add_versions("v1.8.0", "2ec0a4d33d6f521c942eeaf473d42d5fe139abcfa57d2beffe10c5cf7d34ae60")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("qr-code-generator-c")
                set_kind("$(kind)")
                set_languages("c99")
                add_files("c/qrcodegen.c")
                add_headerfiles("c/qrcodegen.h")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "qrcodegen.h"

            void test() {
                const char *text = "Hello, world!";                // User-supplied text
                enum qrcodegen_Ecc errCorLvl = qrcodegen_Ecc_LOW;  // Error correction level
                
                // Make and print the QR Code symbol
                uint8_t qrcode[qrcodegen_BUFFER_LEN_MAX];
                uint8_t tempBuffer[qrcodegen_BUFFER_LEN_MAX];
                qrcodegen_encodeText(text, tempBuffer, qrcode, errCorLvl,
                    qrcodegen_VERSION_MIN, qrcodegen_VERSION_MAX, qrcodegen_Mask_AUTO, true);
            }
        ]]}, {configs = {languages = "c99"}}))
    end)
