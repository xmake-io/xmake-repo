package("ignite3")
    set_homepage("https://ignite.apache.org")
    set_description("Apache Ignite 3 C++ client library")
    set_license("Apache-2.0")

    add_urls("https://archive.apache.org/dist/ignite/$(version)/apache-ignite-$(version)-cpp.zip",
             "https://mirror.fi.ossplanet.net/apache-dist/ignite/$(version)/apache-ignite-$(version)-cpp.zip")
    add_versions("3.0.0", "4ef0b6b103fb1d652c486e5783105ca9c81b3ad677248b922d56064e7429ce2f")

    add_configs("client", {description = "Build Ignite C++ client", default = false,  type = "boolean"})
    add_configs("odbc",   {description = "Build ODBC driver",       default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("msgpack-c", "mbedtls")

    on_load(function (package)
        if package:config("client") or package:config("odbc") then
            package:add("deps", "openssl")
            if package:is_plat("windows", "mingw") then
                package:add("syslinks", "wsock32", "ws2_32", "iphlpapi", "crypt32")
            elseif package:is_plat("linux", "bsd") then
                package:add("syslinks", "dl")
            end
        end
    end)

    on_check(function (package)
        assert(not (package:is_subhost("msys")),"This package cannot build on Msys")
        assert(not (package:is_plat("linux") and package:is_arch("arm64")),"This package cannot build on Linux Arm64")
    end)

    on_install("windows", "macosx", "linux", "mingw", function (package)
        io.replace("CMakeLists.txt", "if (CLANG_FORMAT_BIN)", "if(0)", {plain = true})
        -- remove pic hardcode
        io.replace("ignite/network/CMakeLists.txt", "set_target_properties(${TARGET} PROPERTIES POSITION_INDEPENDENT_CODE 1)", "", {plain = true})
        io.replace("cmake/dependencies.cmake", "set(CMAKE_POSITION_INDEPENDENT_CODE ON)", "", {plain = true})
        -- fix find package
        io.replace("cmake/dependencies.cmake", "find_package(msgpack REQUIRED)", "find_package(msgpack-c CONFIG REQUIRED)", {plain = true})
        io.replace("cmake/dependencies.cmake", [[message( FATAL_ERROR "With USE_LOCAL_DEPS specified you have to set MBEDTLS_SOURCE_DIR to path to the MbedTLS source code")]], "find_package(MbedTLS CONFIG REQUIRED)\nreturn()", {plain = true})
        -- fix install headers
        io.replace("ignite/common/CMakeLists.txt", "uuid.h", "uuid.h\n    detail/mpi.h", {plain = true})
        io.replace("ignite/common/detail/bytes.h", "detail/config.h", "config.h", {plain = true})
        -- Install ignite-common target
        io.replace("ignite/common/CMakeLists.txt", [[ignite_install_headers(FILES ${PUBLIC_HEADERS} DESTINATION ${IGNITE_INCLUDEDIR}/common)]], [[ignite_install_headers(FILES ${PUBLIC_HEADERS} DESTINATION ${IGNITE_INCLUDEDIR}/common)
install(TARGETS ${PROJECT_NAME} ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}" LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}" RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")]], {plain = true})
        -- Enforce search for MBEDTLS
        io.replace("ignite/common/CMakeLists.txt", [[target_link_libraries(${TARGET} PUBLIC MbedTLS::mbedtls)]], [[
find_package(MbedTLS CONFIG REQUIRED)
target_link_libraries(${TARGET} PUBLIC MbedTLS::mbedtls)]], {plain = true})
        local configs = {
            "-DENABLE_TESTS=OFF",
            "-DCMAKE_INSTALL_INCLUDEDIR=" .. path.unix(package:installdir("include")),
            "-DWARNINGS_AS_ERRORS=OFF",
            "-DUSE_LOCAL_DEPS=ON",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_ADDRESS_SANITIZER=" .. (package:config("asan") and "ON" or "OFF"))
        table.insert(configs,"-DENABLE_CLIENT=" .. (package:config("client") and "ON" or "OFF"))
        table.insert(configs,"-DENABLE_ODBC="   .. (package:config("odbc")   and "ON" or "OFF"))
        local opt = {}
        opt.cxflags = "-DMBEDTLS_ALLOW_PRIVATE_ACCESS"
        import("package.tools.cmake").install(package, configs, opt)
        if package:is_plat("windows") and not package:config("shared") then
            io.replace(package:installdir("include/ignite/common/detail/config.h"), "# define IGNITE_API IGNITE_IMPORT", "# define IGNITE_API", {plain = true})
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <ignite/tuple/binary_tuple_builder.h>
            void test() {
                ignite::binary_tuple_builder builder{0};
                builder.start();
            }
        ]]}, {configs = {languages = "c++17"}}))
        if package:config("client") then
            assert(package:check_cxxsnippets({test = [[
                #include <ignite/client/ignite_client.h>
                void test() {
                    ignite::IgniteClientConfiguration cfg;
                    ignite::IgniteClient::Start(cfg, std::chrono::seconds(1),
                                                [](ignite::IgniteClient&){});
                }
            ]]}, {configs = {languages = "c++17"}}))
        end
    end)
