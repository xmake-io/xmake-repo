package("pulsar")
    set_homepage("https://github.com/apache/pulsar-client-cpp")
    set_description("Pulsar C++ client library")

    add_urls("https://github.com/apache/pulsar-client-cpp/archive/refs/tags/v$(version).tar.gz")

    add_versions("3.1.2", "802792e8dd48f21dea0cb9cee7afe20f2598d333d2e484a362504763d1e3d49a")

    add_deps("boost 1.81.0", "protobuf-cpp", "libcurl", "openssl", "zlib", "zstd", "snappy")

    on_install("linux", function (package)
        local configs = {"-DBUILD_TESTS=OFF"}
        if package:config("shared") then
            configs = table.join(configs, {"-DBUILD_STATIC_LIB=OFF", "-DBUILD_DYNAMIC_LIB=ON"})
        else
            configs = table.join(configs, {"-DBUILD_STATIC_LIB=ON", "-DBUILD_DYNAMIC_LIB=OFF"})
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = {"zstd", "snappy"}})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            #include <pulsar/Client.h>

            void test(int argc, char** argv) {
                try {
                    pulsar::Client client {"some_invalid_svc_url"};
                } catch (std::invalid_argument) {
                    std::cout << "invalid argument" << std::endl;
                }
            }
        ]]}, {configs = {languages = "cxx11"}}))
    end)
