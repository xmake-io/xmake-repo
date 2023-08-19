package("zmqpb")
    set_homepage("https://github.com/SFGrenade/ZmqPb/")
    set_description("A helper to use zeromq and protobuf together")
    set_license("MPL-2.0")

    set_urls("https://github.com/SFGrenade/ZmqPb/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/SFGrenade/ZmqPb.git")
    add_versions("0.1", "4a34ec92faa381306356e84e2a2000093d8f76cfa037db1f4cd0adb0205faebb")

    add_deps("cppzmq")
    add_deps("fmt")
    add_deps("protobuf-cpp")

    on_install(function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        elseif not package:is_plat("windows", "mingw") and package:config("pic") ~= false then
            configs.cxflags = "-fPIC"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                ZmqPb::ReqRep network( "tcp://127.0.0.1", 13337, false );
                network.run();
            }
        ]]}, {configs = {languages = "c++14"}, includes = "zmqPb/reqRep.hpp"}))
    end)
