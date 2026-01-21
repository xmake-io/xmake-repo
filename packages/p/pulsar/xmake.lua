package("pulsar")
    set_homepage("https://github.com/apache/pulsar-client-cpp")
    set_description("Pulsar C++ client library")
    set_license("Apache-2.0")

    add_urls("https://github.com/apache/pulsar-client-cpp/archive/refs/tags/v$(version).tar.gz")

    add_versions("3.7.2", "f0d4339168b3c5fbdbd0e3c304de9854535b70b3f5811f2f18278f1608e67c5a")
    add_versions("3.6.0", "321e288e60b340155d9a9ad8eb823738047f5055a71a8a345c93ddbe3d023741")
    add_versions("3.5.1", "279debf04b566321ff4fe2c5bd5bef8547a20b2bdbc6943cb027224ce6b45ec4")
    add_versions("3.5.0", "21d71a36666264418e3c5d3bc745628228b258daf659e6389bb9c9584409a27e")
    add_versions("3.1.2", "802792e8dd48f21dea0cb9cee7afe20f2598d333d2e484a362504763d1e3d49a")

    add_deps("boost 1.81.0", "protobuf-cpp", "libcurl", "openssl", "zlib", "zstd", "snappy", "abseil", "utf8_range")

    on_install("linux", function (package)
        io.replace("CMakeLists.txt", "-Werror", "")
        local configs = {"-DBUILD_TESTS=OFF", "-DCMAKE_CXX_STANDARD=17"}
        if package:config("shared") then
            configs = table.join(configs, {"-DBUILD_STATIC_LIB=OFF", "-DBUILD_DYNAMIC_LIB=ON"})
        else
            configs = table.join(configs, {"-DBUILD_STATIC_LIB=ON", "-DBUILD_DYNAMIC_LIB=OFF"})
        end
        io.replace("CMakeLists.txt", "add_subdirectory(examples)", "", {plain = true})
        import("package.tools.cmake").install(package, configs, {packagedeps = {"zstd", "snappy", "abseil", "utf8_range"}})
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
        ]]}, {configs = {languages = "cxx17"}}))
    end)
