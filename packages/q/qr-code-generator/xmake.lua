package("qr-code-generator")
    set_kind("library", {headeronly = true})
    set_homepage("https://www.nayuki.io/page/qr-code-generator-library")
    set_description("High-quality QR Code generator library in Java, TypeScript/JavaScript, Python, Rust, C++, C.")

    add_urls("https://github.com/nayuki/QR-Code-generator/archive/refs/tags/$(version).tar.gz",
             "https://github.com/nayuki/QR-Code-generator.git")

    add_versions("v1.8.0", "2ec0a4d33d6f521c942eeaf473d42d5fe139abcfa57d2beffe10c5cf7d34ae60")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("qr-code-generator")
                set_kind("$(kind)")
                set_languages("cxx11")
                add_files("cpp/qrcodegen.cpp")
                add_headerfiles("cpp/qrcodegen.hpp")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "qrcodegen.hpp"

            using namespace qrcodegen;
            void test() {
                const char *text = "Hello, world!";
                const QrCode::Ecc errCorLvl = QrCode::Ecc::LOW;
                const QrCode qr = QrCode::encodeText(text, errCorLvl);
            }
        ]]}))
    end)
