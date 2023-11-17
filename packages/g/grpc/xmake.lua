package("grpc")
    set_homepage("https://grpc.io")
    set_description("The C based gRPC (C++, Python, Ruby, Objective-C, PHP, C#)")
    set_license("Apache-2.0")

    add_urls("https://github.com/grpc/grpc/archive/refs/tags/$(version).zip",
             "https://github.com/grpc/grpc.git")
    add_versions("v1.51.3", "17720fd0a690e904a468b4b3dae6fa5ec40b0d1f4d418e2ca092e2f92f06fce0")

    add_patches("1.51.3", path.join(os.scriptdir(), "patches", "1.51.3", "disable-download-archive.patch"), "90fdd6e4a51cbc9756d1fcdd0f65e665d4b78cfd91fdbeb0228cc4e9c4ba1b73")
    add_patches("1.51.3", path.join(os.scriptdir(), "patches", "1.51.3", "static-linking-in-linux.patch"), "176474919883f93be0c5056098eccad408038663c6c7361f2e049cdf7247a19c")

    add_deps("cmake")
    if is_plat("linux") then
        add_deps("autoconf", "libtool", "pkg-config")
        add_extsources("apt::build-essential")
    elseif is_plat("macosx") then
        add_deps("autoconf", "automake", "libtool")
        add_extsources("brew::shtool")
    elseif is_plat("windows") then
        add_deps("nasm")
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("c-ares", "re2", "abseil", "protobuf-cpp", "openssl", "zlib")

    if is_plat("linux") then
        add_syslinks("pthread", "dl", "m")
    end

    add_links("grpc++", "grpc++_unsecure", "grpc++_alts", "grpc++_reflection", "grpc++_error_details", "grpcpp_channelz")
    add_links("grpc", "grpc_unsecure", "grpc_plugin_support", "gpr")
    add_links("address_sorting", "upb") --TODO we should add seperate package deps

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_install("linux", "macosx", "windows", function (package)
        local configs = {
            "-DCMAKE_CXX_STANDARD=17", -- abseil need c++17
            "-DgRPC_BUILD_TESTS=OFF",
            "-DgRPC_ZLIB_PROVIDER=package",
            "-DgRPC_ABSL_PROVIDER=package",
            "-DgRPC_CARES_PROVIDER=package",
            "-DgRPC_RE2_PROVIDER=package",
            "-DgRPC_SSL_PROVIDER=package",
            "-DgRPC_PROTOBUF_PROVIDER=package",
            "-DgRPC_UPB_PROVIDER=module", -- TODO
            "-DgRPC_BENCHMARK_PROVIDER=none",
            "-DgRPC_PROTOBUF_PACKAGE_TYPE=CONFIG"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        if package:is_binary() then
            assert(os.isfile(path.join(package:installdir(), "bin", "grpc_cpp_plugin")))
        else
            assert(package:check_cxxsnippets({test = [[
                #include <iostream>
                void test() {
                    grpc::CompletionQueue q;
                    std::string server_address("192.168.28.109:9010");
                    auto channel = grpc::CreateChannel(server_address, grpc::InsecureChannelCredentials());
                    std::cout << &channel << std::endl;
                }
            ]]}, {configs = {languages = "c++17"}, includes = "grpcpp/grpcpp.h"}))
        end
    end)
