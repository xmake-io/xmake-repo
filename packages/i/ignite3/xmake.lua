package("ignite3")
    set_homepage("https://ignite.apache.org")
    set_description("Apache Ignite 3 C++ client library")
    set_license("Apache-2.0")

    add_urls("https://archive.apache.org/dist/ignite/$(version)/apache-ignite-$(version)-cpp.zip")
    add_versions("3.0.0", "4ef0b6b103fb1d652c486e5783105ca9c81b3ad677248b922d56064e7429ce2f")

    add_configs("client", {description = "Build Ignite C++ client", default = true,  type = "boolean"})
    add_configs("odbc",   {description = "Build ODBC driver",      default = false, type = "boolean"})
    add_configs("tests",  {description = "Build unit tests",       default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("msgpack-c", "mbedtls")

    on_load(function (package)
        if package:config("tests") then
            package:add("deps", "gtest", {configs = {main = true}})
        end
    end)

    on_install(function (package)
        local cmake   = import("package.tools.cmake")

        local configs = {"-DCMAKE_POSITION_INDEPENDENT_CODE=ON"}
        table.insert(configs,"-DINSTALL_IGNITE_FILES=OFF")
        table.insert(configs,"-DWARNINGS_AS_ERRORS=OFF")
        table.insert(configs,"-DUSE_LOCAL_DEPS=ON")
        table.insert(configs,"-DENABLE_CLIENT=" .. (package:config("client") and "ON" or "OFF"))
        table.insert(configs,"-DENABLE_ODBC="   .. (package:config("odbc")   and "ON" or "OFF"))
        table.insert(configs,"-DENABLE_TESTS="  .. (package:config("tests")  and "ON" or "OFF"))
        

        cmake.install(package, configs, {
            external  = {
                msgpack_DIR = package:dep("msgpack-c"):installdir(),
                mbedtls_DIR = package:dep("mbedtls"):installdir()
            }
        })
    end)

    on_test(function (package)
        if package:config("client") then
            assert(package:check_cxxsnippets({test = [[
                #include <ignite/client/ignite_client.h>
                int main() {
                    ignite::IgniteClientConfiguration cfg;
                    ignite::IgniteClient::Start(cfg, std::chrono::seconds(1),
                                                [](ignite::IgniteClient&){});
                    return 0;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end
    end)
