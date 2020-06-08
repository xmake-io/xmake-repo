package("protobuf-cpp")

    set_homepage("https://developers.google.com/protocol-buffers/")
    set_description("Google's data interchange format for cpp")

    add_urls("https://github.com/protocolbuffers/protobuf/releases/download/v$(version)/protobuf-cpp-$(version).zip")
    add_versions("3.8.0", "91ea92a8c37825bd502d96af9054064694899c5c7ecea21b8d11b1b5e7e993b5")
    add_versions("3.12.3", "74da289e0d0c24b2cb097f30fdc09fa30754175fd5ebb34fae4032c6d95d4ce3")

    if is_plat("windows") then
        add_deps("cmake")
    end

    if is_plat("windows") then
        add_links("libprotobuf")
    else
        add_links("protobuf")
    end

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_install("windows", function (package)
        os.cd("cmake")
        import("package.tools.cmake").install(package, {"-Dprotobuf_BUILD_PROTOC_BINARIES=ON"})
        os.cp("build_*/Release/protoc.exe", package:installdir("bin"))
    end)

    on_install("linux", "macosx", function (package)
        import("package.tools.autoconf").install(package, {"--enable-shared=no"})
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
        assert(package:check_cxxsnippets({test = io.readfile("test.pb.cc")}, {configs = {includedirs = {".", package:installdir("include")}, languages = "c++11"}}))
    end)
