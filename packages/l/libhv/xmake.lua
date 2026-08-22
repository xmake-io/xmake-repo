package("libhv")
    set_homepage("https://github.com/ithewei/libhv")
    set_description("Like libevent, libev, and libuv, libhv provides event-loop with non-blocking IO and timer, but simpler api and richer protocols.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/ithewei/libhv.git")
    add_urls("https://github.com/ithewei/libhv/archive/refs/tags/$(version).zip", {excludes = {"*/html/*"}})

    add_versions("v1.0.0", "39adb77cc7addaba82b69fa9a433041c8288f3d9c773fa360162e3391dcf6a7b")
    add_versions("v1.1.0", "a753c268976d9c4f85dcc10be2377bebc36d4cb822ac30345cf13f2a7285dbe3")
    add_versions("v1.1.1", "e012d9752fe8fb3f788cb6360cd9abe61d4ccdc1d2085501d85f1068eba8603e")
    add_versions("v1.2.1", "d658a8e7f1a3b2f3b0ddcabe3b13595b70246c94d57f2c27bf9a9946431b2e63")
    add_versions("v1.2.2", "a15ec12cd77d1fb745a74465b8bdee5a45247e854371db9d0863573beca08466")
    add_versions("v1.2.3", "c30ace04597a0558ce957451d64acc7cd3260d991dc21628e048c8dec3028f34")
    add_versions("v1.2.4", "389fa60f0d6697b5267ddc69de00e4844f1d8ac8ee4d2ad3742850589c20d46e")
    add_versions("v1.2.6", "dd5ed854f5cdc0bdd3a3310a9f0452ec194e2907006551aebbb603825a989ed1")
    add_versions("v1.3.0", "e7a129dcabb541baeb8599e419380df6aa98afc6e04874ac88a6d2bdb5a973a5")
    add_versions("v1.3.1", "66fb17738bc51bee424b6ddb1e3b648091fafa80c8da6d75626d12b4188e0bdc")
    add_versions("v1.3.2", "61d6d5fadf13d81c111df4514e0e61062fead21c2a8b6c4caf7706f9b002fae1")
    add_versions("v1.3.3", "f78d1012ddf82506c28dda573ce303912e6cd5e707a358a249db1cc7e1e82238")
    add_versions("v1.3.4", "966866873897ff4a7c526c3f6f1d00d7c13027aa5eef16270a5c5b4094dbdf95")

    add_configs("protocol",    {description = "compile protocol", default = false, type = "boolean"})
    add_configs("http",        {description = "compile http", default = true, type = "boolean"})
    add_configs("http_server", {description = "compile http/server", default = true, type = "boolean"})
    add_configs("http_client", {description = "compile http/client", default = true, type = "boolean"})
    add_configs("consul",      {description = "compile consul", default = false, type = "boolean"})
    add_configs("ipv6",        {description = "enable ipv6", default = false, type = "boolean"})
    add_configs("uds",         {description = "enable Unix Domain Socket", default = false, type = "boolean"})
    add_configs("windump",     {description = "enable Windows MiniDumpWriteDump", default = false, type = "boolean"})
    add_configs("multimap",    {description = "use MultiMap", default = false, type = "boolean"})
    add_configs("curl",        {description = "with curl library", default = false, type = "boolean"})
    add_configs("nghttp2",     {description = "with nghttp2 library", default = false, type = "boolean"})
    add_configs("openssl",     {description = "with openssl library", default = false, type = "boolean"})
    add_configs("mbedtls",     {description = "with mbedtls library", default = false, type = "boolean"})
    add_configs("gnutls",      {description = "with gnutls library", default = false, type = "boolean"})

    if is_plat("linux") then
        add_syslinks("pthread")
    elseif is_plat("macosx", "iphoneos") then
        add_frameworks("CoreFoundation", "Security")
    elseif is_plat("windows") then
        add_syslinks("crypt32", "advapi32")
    elseif is_plat("mingw") then
        add_syslinks("crypt32", "ws2_32", "secur32")
        add_syslinks("pthread")
    end

    add_deps("cmake")
    add_deps("nlohmann_json", {configs = {cmake = true}})

    on_load(function (package)
        if package:config("openssl") then
            package:add("deps", "openssl")
        elseif package:config("mbedtls") then
            package:add("deps", "mbedtls")
        elseif package:config("curl") then
            package:add("deps", "libcurl")
        elseif package:config("nghttp2") then
            package:add("deps", "nghttp2")
        end

        if not package:config("shared") then
            package:add("defines", "HV_STATICLIB")
        end
    end)

    on_install("cross", "windows", "linux", "macosx", "android", "iphoneos", "mingw@windows", function(package)
        local configs = {"-DBUILD_EXAMPLES=OFF", "-DBUILD_UNITTEST=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))

        os.rm("cpputil/json.hpp")
        io.replace("cmake/vars.cmake", "cpputil/json.hpp", "", {plain = true})
        io.replace("CMakeLists.txt", [[target_link_libraries(hv ${LIBS})]],
            [[find_package(nlohmann_json CONFIG REQUIRED)
target_link_libraries(hv ${LIBS} nlohmann_json::nlohmann_json)]], {plain = true})
        io.replace("CMakeLists.txt", [[target_link_libraries(hv_static ${LIBS})]],
            [[find_package(nlohmann_json CONFIG REQUIRED)
target_link_libraries(hv_static ${LIBS} nlohmann_json::nlohmann_json)]], {plain = true})

        -- Fix PDB file installation issue for Windows static library builds
        io.replace("CMakeLists.txt", 
            [[if(WIN32 AND NOT MINGW)
    install(FILES $<TARGET_PDB_FILE:${PROJECT_NAME}> DESTINATION bin OPTIONAL)
endif()]],
            [[if(WIN32 AND NOT MINGW)
    if(BUILD_SHARED)
        install(FILES $<TARGET_PDB_FILE:hv> DESTINATION bin OPTIONAL)
    endif()
endif()]], {plain = true})

        for _, suffix in ipairs({"**.h", "**.cpp"}) do
            for _, file in ipairs(os.files(suffix)) do
                io.replace(file, [[#include "json.hpp"]], [[#include <nlohmann/json.hpp>]], {plain = true})
            end
        end

        for _, name in ipairs({"with_protocol",
                               "with_http",
                               "with_http_server",
                               "with_http_client",
                               "with_consul",
                               "with_curl",
                               "with_nghttp2",
                               "with_openssl",
                               "with_mbedtls",
                               "enable_ipv6",
                               "enable_uds",
                               "enable_windump",
                               "use_multimap",
                               "with_gnutls"}) do
            local config_name = name:gsub("with_", ""):gsub("use_", ""):gsub("enable_", "")
            table.insert(configs, "-D" .. name:upper() .. "=" .. (package:config(config_name) and "ON" or "OFF"))
        end
        local packagedeps = {}
        if package:config("openssl") then
            table.insert(packagedeps, "openssl")
        elseif package:config("mbedtls") then
            table.insert(packagedeps, "mbedtls")
        end
        if package:is_plat("iphoneos") then
            io.replace("ssl/appletls.c", "ret = SSLSetProtocolVersionEnabled(appletls->session, kSSLProtocolAll, true);",
                "ret = SSLSetProtocolVersionMin(appletls->session, kTLSProtocol12);", {plain = true})
        elseif package:is_plat("windows") and package:is_arch("arm.*") then
            io.replace("base/hplatform.h", "defined(__arm__)", "defined(__arm__) || defined(_M_ARM)", {plain = true})
            io.replace("base/hplatform.h", "defined(__aarch64__) || defined(__ARM64__)", "defined(__aarch64__) || defined(__ARM64__) || defined(_M_ARM64)", {plain = true})
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = packagedeps})
    end)

    on_test(function(package)
        assert(package:has_cfuncs("hloop_new", {includes = "hv/hloop.h"}))
        assert(package:check_cxxsnippets({test = [[
            #include "hv/hv.h"
            void test() {
                const char* version = hv_compile_version();
                printf("%s\n", version);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
