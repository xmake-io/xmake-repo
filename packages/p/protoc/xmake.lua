package("protoc")
    set_kind("binary")
    set_base("protobuf-cpp")

    on_load(function (package)
        package:base():plat_set(package:plat())
        package:base():arch_set(package:arch())
        package:base():script("load")(package)
    end)

    on_install("@windows", "@linux", "@macosx", "@bsd", "@msys", function (package)
        package:base():script("install")(package)
    end)

    on_test(function (package)
        if is_subhost("msys") and package:is_plat("mingw", "msys") and package:is_arch("i386") then
            return
        end

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
