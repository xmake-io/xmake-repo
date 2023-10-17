package("oatpp-websocket")
    set_homepage("https://oatpp.io/")
    set_description("It provides WebSocket functionality for oatpp applications.")
    set_license("Apache-2.0")

    add_urls("https://github.com/oatpp/oatpp-websocket/archive/$(version).tar.gz",
             "https://github.com/oatpp/oatpp-websocket.git")
    add_versions("1.0.0", "2e4ed596d1e8c15f0b9c6d5ba994b8fde623a6dfd256a17c8f99d86427115981")
    add_versions("1.2.5", "b930034aaed40715ccc9b9df094292ea6e2a44f31bf830d1e15db5255ece9184")
    add_versions("1.3.0", "8215765238c595e296c9ea961670064ff9c44e3e0f9accda59d81b10cc29873b")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    add_deps("oatpp")

    on_load(function (package)
        package:add("includedirs", path.join("include", "oatpp-" .. package:version_str(), "oatpp-websocket"))
        package:add("linkdirs", path.join("lib", "oatpp-" .. package:version_str()))
    end)

    on_install("linux", "macosx", "windows|x64", function (package)
        local configs = {"-DOATPP_BUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DOATPP_MSVC_LINK_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "oatpp-websocket/SHA1.hpp"
            void test() {
                oatpp::String message = "oat++ web framework";
                oatpp::String messageEncoded = "43e1bad62b6b4a1e88c9de60435335b5b7518f4a";
                {
                    oatpp::websocket::SHA1 sha;
                    sha.update(message);
                    oatpp::String encoded = sha.finalBinary();
                    OATPP_ASSERT(encoded == messageEncoded);
                }
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
