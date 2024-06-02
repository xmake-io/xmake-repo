package("srpc")
    set_homepage("https://github.com/sogou/srpc")
    set_description("RPC framework based on C++ Workflow. Supports SRPC, Baidu bRPC, Tencent tRPC, thrift protocols.")
    set_license("Apache-2.0")

    add_urls("https://github.com/sogou/srpc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/sogou/srpc.git")

    add_versions("v0.10.2", "da570f3522e9dfec9c396632044fcb51b5ddc5c854ba7824d1770de138f469fb")

    add_deps("cmake", "protobuf-cpp")
    add_deps("workflow", "snappy", "lz4", "zlib")

    on_install("linux", "macosx", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        os.rm("third_party")
        io.replace("CMakeLists.txt", 'check_include_file_cxx("workflow/Workflow.h" WORKFLOW_INSTALLED)',
            "set(WORKFLOW_INSTALLED TRUE)", {plain = true})
        import("package.tools.cmake").install(package, configs, {packagedeps = {
            "workflow", "snappy", "lz4", "zlib"}})
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
