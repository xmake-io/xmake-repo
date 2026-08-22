package("brpc")
    set_homepage("https://brpc.apache.org")
    set_description("brpc is an Industrial-grade RPC framework using C++ Language, which is often used in high performance system such as Search, Storage, Machine learning, Advertisement, Recommendation etc.")
    set_license("Apache-2.0")

    add_urls("https://github.com/apache/brpc/archive/refs/tags/$(version).tar.gz")

    add_versions("1.16.0", "60f218554527f05ad8fae3cb8f81879d0c7dc72b249cde132049c44b1a73e76d")
    add_versions("1.15.0", "f674b753af71dc313d9d2dcf34f574f0a3438c9f9bb9e7e6ca500a3b0ca7ddfb")
    add_versions("1.14.1", "9d07cf40e7c6c70210b032cd69b0b525459d204ebb8068ca93678c13807e2af1")
    add_versions("1.10.0", "fe4eb10b4ca1a59e0f71086552b2d8897afd66df93b53c18ad83f6a93717cc2d")
    add_versions("1.8.0", "13ffb2f1f57c679379a20367c744b3e597614a793ec036cd7580aae90798019d")
    add_versions("1.7.0", "48668cbc943edd1b72551e99c58516249d15767b46ea13a843eb8df1d3d1bc42")
    add_versions("1.6.1", "d9eb93683b0e4cb583aacdf2357c3e3e613fbf797c4fafd0eae1d09d5ea50964")
    add_versions("1.4.0", "6ea39d8984217f62ef954b7ebc0dfa724c62472a5ae7033ed189f994f28b9e30")
    add_versions("1.5.0", "5ce178e3070ecdf9576a8917e3f65d96085f437bfbf9f1d09d46bca1375938cf")
    add_versions("1.3.0", "b9d638b76725552ed11178c650d7fc95e30f252db7972a93dc309a0698c7d2b8")

    add_patches("1.15.0", path.join(os.scriptdir(), "patches", "1.15.0", "cmake.patch"), "656ee11363d1d0d084ecf08a1ecde6ba1267485a000937015d4d9005a29c89ec")
    add_patches("1.14.1", path.join(os.scriptdir(), "patches", "1.14.1", "cmake.patch"), "04de26217d7fef37cf6e4d072cc65d767cf7d363b936d8cd652235be6f11e0c9")
    add_patches("1.10.0", path.join(os.scriptdir(), "patches", "1.8.0", "cmake.patch"), "315889dcca66331932a8ce90bbdc5f71e336ca39d625ff85a589ee2bf10155ee")
    add_patches("1.8.0", path.join(os.scriptdir(), "patches", "1.8.0", "cmake.patch"), "315889dcca66331932a8ce90bbdc5f71e336ca39d625ff85a589ee2bf10155ee")
    add_patches("1.7.0", path.join(os.scriptdir(), "patches", "1.7.0", "cmake.patch"), "801920d6fcd20f3da68c1846dc22d26d2d320e48b06b6b5bd38bbed11e5ebd2c")
    add_patches("1.6.1", path.join(os.scriptdir(), "patches", "1.6.1", "cmake.patch"), "046e590994ad302127d4cb7b1b2d8231db5f7c30c3948a0172d0dca9bef1da0b")
    add_patches("1.5.0", path.join(os.scriptdir(), "patches", "1.5.0", "cmake.patch"), "af6eb76c9eccedaba1ff39d8f36280a09f0476848b24ef5330a350cd06900244")
    add_patches("1.4.0", path.join(os.scriptdir(), "patches", "1.4.0", "cmake.patch"), "006fa842e84a6e8091f236a12e7c44dd60962cc61fddf46bcfc65a2093383cef")
    add_patches("1.3.0", path.join(os.scriptdir(), "patches", "1.3.0", "cmake.patch"), "a71bf46a4a6038a89da3ee9057dea5f452155a2da1f1c9bdcae7ecd0bb5e0510")

    -- we enable zlib in protobuf-cpp, because brpc need google/protobuf/io/gzip_stream.h
    add_deps("protobuf-cpp 3.19.4", {configs = {zlib = true}})
    add_deps("leveldb", "gflags", "openssl", "libzip", "snappy", "zlib")
    add_deps("cmake")

    if is_plat("macosx") then
        add_frameworks("Foundation", "CoreFoundation", "Security", "CoreGraphics", "CoreText", "CoreData")
        add_ldflags("-Wl,-U,_MallocExtension_ReleaseFreeMemory", "-Wl,-U,_ProfilerStart", "-Wl,-U,_ProfilerStop", "-Wl,-U,__Z13GetStackTracePPvii", "-Wl,-U,_RegisterThriftProtocol", "-Wl,-U,_mallctl", "-Wl,-U,_malloc_stats_print")
    elseif is_plat("linux") then
        add_syslinks("rt", "dl")
    end

    on_install("linux", "macosx", function (package)
        local configs = {"-DWITH_DEBUG_SYMBOLS=OFF", "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON", "-DWITH_SNAPPY=ON"}
        io.replace("CMakeLists.txt", 'set(CMAKE_CXX_FLAGS "${CMAKE_CPP_FLAGS}', 'set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CPP_FLAGS}', {plain = true})
        io.replace("CMakeLists.txt", 'set(CMAKE_C_FLAGS "${CMAKE_CPP_FLAGS}', 'set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${CMAKE_CPP_FLAGS}', {plain = true})
        import("package.tools.cmake").install(package, configs, {packagedeps = "zlib"})
        if not package:config("shared") then
            os.rm(package:installdir("lib/*.dylib"))
            os.rm(package:installdir("lib/*.so"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({
            test = [[
              #include <brpc/server.h>
              static void test() {
                brpc::Server server;
              }
            ]]
        }, {configs = {languages = "c++11"}}))
    end)
