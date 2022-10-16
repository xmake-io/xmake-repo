package("brpc")
    set_homepage("https://github.com/apache/incubator-brpc")
    set_description("brpc is an Industrial-grade RPC framework using C++ Language, which is often used in high performance system such as Search, Storage, Machine learning, Advertisement, Recommendation etc.")

    add_urls("https://github.com/apache/incubator-brpc.git")
    add_versions("1.3.0", "a90cf60714941632b2986826336a7c50cbd3d530")

    add_deps("protobuf-cpp 3.19.4")
    add_deps("leveldb", "gflags", "openssl", "libzip")
    add_deps("cmake")

    if is_plat("macosx") then
        add_frameworks("Foundation", "CoreFoundation", "Security", "CoreGraphics", "CoreText")
        add_ldflags("-Wl,-U,_ProfilerStart", "-Wl,-U,_ProfilerStop")
    elseif is_plat("linux") then
        add_syslinks("rt", "dl")
    end

    on_install("linux", "macosx", function (package)
        io.replace("CMakeLists.txt", "${OPENSSL_CRYPTO_LIBRARY}", "", {plain = true})
        io.replace("CMakeLists.txt", "list(APPEND DYNAMIC_LIB ${OPENSSL_SSL_LIBRARY})",
            "list(APPEND DYNAMIC_LIB ${OPENSSL_SSL_LIBRARY} ${OPENSSL_CRYPTO_LIBRARY})", {plain = true})
        local configs = {"-DWITH_DEBUG_SYMBOLS=OFF", "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"}
        import("package.tools.cmake").install(package, configs)
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
