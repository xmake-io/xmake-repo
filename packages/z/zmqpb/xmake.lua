package("zmqpb")
    set_homepage("https://github.com/SFGrenade/ZmqPb-Cpp/")
    set_description("A helper to use zeromq and protobuf together")
    set_license("MPL-2.0")

    set_urls("https://github.com/SFGrenade/ZmqPb-Cpp/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/SFGrenade/ZmqPb-Cpp.git")
    add_versions("0.10.6", "24d69ab541b295d8656958f12757183769338c06a5d89f7544e904e198ea33be")
    add_versions("0.1", "4a34ec92faa381306356e84e2a2000093d8f76cfa037db1f4cd0adb0205faebb")
    add_versions("0.2", "5dfa4d4cebb10cb7ae03943e18e8d48c8ff215e80371f24c5ade212be7f20721")
    add_versions("0.3", "343c57c9f72facca47082422a259ec8c531f5c6e332a3828835080c4a96b9064")
    add_versions("0.4", "7c0001db73b19e65b007adf6c9c5092c3589f043ab3e95a16b3ec2b2a87fa244")
    add_versions("0.8", "93433dfe60b09add321d5f6fd467724409929211010963ad63be6c68494446ed")
    add_versions("0.9", "c4192777fd7d62b3624a6389efea68a772c4f2820c3d85128961c3dd5ee94a67")
    add_versions("0.10.2", "3dc82384cb79cc46262a2ba4007351be8606fadda7b8f399df3cbde9dd77560b")
    add_versions("0.10.3", "01d6b737c5316947eac133589f53c4fb03e28f9b178f3c6a8f2a8956a1ff2932")
    add_versions("0.10.4", "89844672229e4e4a75ddec65bdb1e2e825ef5f4b56667f40a29ec68ff215be45")
    add_versions("0.10.5", "28db7f721d4d63da5f911af369265fdaf63c604858416d32207bc50869dade6f")

    add_deps("cppzmq")
    add_deps("protoc", "protobuf-cpp")

    on_load("windows", "macosx", "linux", function (package)
        if not package:gitref() and package:version():lt("0.3") then
            package:add("deps", "fmt")
        end
        if package:gitref() or package:version():gt("0.8") then
            package:add("deps", "hedley")
            if package:config("shared") then
                package:add("defines", "ZMQPB_IS_SHARED")
            end
        end
        if not package:gitref() and package:version():lt("0.10.2") then
            -- protobuf needed it and somehow just didn't publicizes the linkage
            package:add("deps", "utf8_range")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {}
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        if package:gitref() or package:version():ge("0.3") then
            assert(package:check_cxxsnippets({test = [[
                void test() {
                    ZmqPb::ReqRep network( "tcp://127.0.0.1:13337", false );
                    network.run();
                }
            ]]}, {configs = {languages = "c++17"}, includes = "zmqPb/reqRep.hpp"}))
        else
            assert(package:check_cxxsnippets({test = [[
                void test() {
                    ZmqPb::ReqRep network( "tcp://127.0.0.1", 13337, false );
                    network.run();
                }
            ]]}, {configs = {languages = "c++14"}, includes = "zmqPb/reqRep.hpp"}))
        end
    end)
