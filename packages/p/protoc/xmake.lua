package("protoc")

    set_kind("binary")
    set_homepage("https://developers.google.com/protocol-buffers/")
    set_description("Google's data interchange format compiler")

    if is_host("windows") then
        if is_arch("x64") then
            add_urls("https://github.com/protocolbuffers/protobuf/releases/download/v$(version)/protoc-$(version)-win64.zip")
            add_versions("3.8.0", "ac07cd66824f93026a796482dc85fa89deaf5be1b0e459de9100cff2992e6905")
            add_versions("24.2", "0066a0a9d972080c6be121cc2975a54cfdd68190205277ff5b4a9d188eee6f1d")
        else
            add_urls("https://github.com/protocolbuffers/protobuf/releases/download/v$(version)/protoc-$(version)-win32.zip")
            add_versions("3.8.0", "93c5b7efe418b539896b2952ab005dd81fa418b76abee8c4341b4796b391999e")
            add_versions("24.2", "380aa6855cec387e400125696ce3c92d5315a51692772eeefab3dc3f50df2a09")
        end
    elseif is_host("macosx") then
        if is_arch("x86_64") then
            add_urls("https://github.com/protocolbuffers/protobuf/releases/download/v$(version)/protoc-$(version)-osx-x86_64.zip")
            add_versions("3.8.0", "8093a79ca6f22bd9b178cc457a3cf44945c088f162e237b075584f6851ca316c")
            add_versions("24.2", "335d8623065234734d35b284f36326fbeded4bad88ca20a2df181761f67ca1a5")
        else
            add_urls("https://github.com/protocolbuffers/protobuf/releases/download/v$(version)/protoc-$(version)-osx-x86_32.zip",
                "https://github.com/protocolbuffers/protobuf/releases/download/v$(version)/protoc-$(version)-osx-universal_binary.zip")
            add_versions("3.8.0", "14376f58d19a7579c43ee95d9f87ed383391d695d4968107f02ed226c13448ae")
            add_versions("24.2", "f9b7c33200978c101f4863ad42b70bded66cae37858d7ad3767b8a428e1856c5")
        end
    else
        add_urls("https://github.com/protocolbuffers/protobuf/releases/download/v$(version)/protobuf-cpp-$(version).zip",
            "https://github.com/protocolbuffers/protobuf/releases/download/v$(version)/protobuf-$(version).zip")
        add_versions("3.8.0", "91ea92a8c37825bd502d96af9054064694899c5c7ecea21b8d11b1b5e7e993b5")
        add_versions("24.2", "a5c60cd8fbab18f1a795c5a3046c6ce6af3070a7dbe76de8fb147253478bd674")
    end

    on_install("@windows", "@msys", "@cygwin", "@macosx", function (package)
        os.cp("bin", package:installdir())
        os.cp("include", package:installdir())
    end)

    on_install("@linux", function (package)
        import("package.tools.autoconf").install(package, {"--enable-shared=no", "--enable-static=no"})
    end)

    on_test(function (package)
        io.writefile("test.proto", [[
            syntax = "proto3";
            package test;
            message TestCase {
                string name = 4;
            }
            message Test {
                repeated TestCase case = 1;
            }
        ]])
        os.vrun("protoc test.proto --cpp_out=.")
    end)
