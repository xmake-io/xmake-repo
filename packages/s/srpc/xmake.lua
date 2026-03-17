package("srpc")
    set_homepage("https://github.com/sogou/srpc")
    set_description("RPC framework based on C++ Workflow. Supports SRPC, Baidu bRPC, Tencent tRPC, thrift protocols.")
    set_license("Apache-2.0")

    add_urls("https://github.com/sogou/srpc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/sogou/srpc.git")

    add_versions("v0.10.4", "7fb90d40263b5fbabf616a963096ee70c8768722a534d55862dd4f50675a0024")
    add_versions("v0.10.3", "8fc8d5d0d0b0975ed4a5d266e82841c4e94eb041cb459357b92dba4e3b64ebb8")
    add_versions("v0.10.2", "da570f3522e9dfec9c396632044fcb51b5ddc5c854ba7824d1770de138f469fb")

    add_deps("cmake", "protobuf-cpp 3.19.4", "abseil", "utf8_range")
    add_deps("workflow", "snappy", "lz4", "zlib")

    on_install("linux", "macosx", function (package)
        local configs = {"-DCMAKE_CXX_STANDARD=17"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        os.rm("third_party")
        io.replace("CMakeLists.txt", 'check_include_file_cxx("workflow/Workflow.h" WORKFLOW_INSTALLED)',
            "set(WORKFLOW_INSTALLED TRUE)", {plain = true})
        import("package.tools.cmake").install(package, configs, {packagedeps = {
            "workflow", "snappy", "lz4", "zlib", "abseil", "utf8_range"}})
        if package:config("shared") then
            os.rm(path.join(package:installdir("lib"), "*.a"))
        else
            os.tryrm(path.join(package:installdir("lib"), "*.dylib"))
            os.tryrm(path.join(package:installdir("lib"), "*.so"))
        end
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        os.vrun("srpc_generator --version")
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            void test() {
                std::cout << srpc::GET_CURRENT_MS() << std::endl;
            }
        ]]}, {configs = {languages = "c++17"}, includes = "srpc/rpc_basic.h"}))
    end)
