package("protoc")
    set_kind("binary")
    set_homepage("https://developers.google.com/protocol-buffers/")
    set_description("Google's data interchange format compiler")

    add_deps("protobuf-cpp")

    on_install("@windows", "@linux", "@macosx", "@bsd", "@msys", "@cygwin", function (package)
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
