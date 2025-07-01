package("capnproto")

    set_homepage("https://github.com/capnproto/capnproto")
    set_description("Cap'n Proto serialization/RPC system - core tools and C++ library.")
    set_license("MIT")

    add_urls("https://github.com/capnproto/capnproto/archive/v$(version).zip")
    add_urls("https://github.com/capnproto/capnproto.git")

    add_versions("1.1.0", "cefc757d4ee07acb17070b0c5c90bfa106b79468670869052246712bf8781fd9")
    add_versions("1.0.2", "3c9afa5dffa4d81a3cbd0581a15a5b1633feaf43093a3b108aded0f636622752")
    add_versions("0.9.0", "18cf46aa4e05446a3d34bad8d56f9d0c73e72020a2b7548b6ec7cb7b1a828d5b")
    add_versions("0.8.0", "9a5e090b1f3ad39bb47fed5fd03672169493674ce273418b76c868393fced2e4")
    add_versions("0.7.0", "1054a879e174b8f797f1b506fedb14ecba5556c656e33ac51bd0a62bd90f925f")

    add_links("capnpc", "capnp-json", "capnp", "capnp-websocket", "capnp-rpc")
    add_links("kj-gzip", "kj-async", "kj-http", "kj", "kj-test", "kj-tls")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end
    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake", "zlib")

    -- Add on_check to fail for version greater than 1.0.2 on Windows ARM and MingW
    on_check(function (package)
        if package:version() >= "1.0.2" then
            if package:is_plat("windows") and package:is_arch("arm.*") then
                raise("package(capnproto): Unsupported version on Windows ARM. Version 0.9.0 is the latest supported version on Windows ARM.")
            end
            if package:is_plat("mingw") then
                raise("package(capnproto): Unsupported version on MingW. Version 0.9.0 is the latest supported version on MingW.")
            end
        end
    end)

    on_install("windows", "mingw@windows,msys", "linux", "macosx", "bsd", function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "capnp/message.h"
            void test() {
                capnp::MallocMessageBuilder message;
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
