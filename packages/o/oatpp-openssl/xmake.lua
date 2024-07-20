package("oatpp-openssl")
    set_homepage("https://oatpp.io/")
    set_description("It provides secure server and client connection providers for oatpp applications.")
    set_license("Apache-2.0")

    add_urls("https://github.com/oatpp/oatpp-openssl/archive/$(version).tar.gz",
             "https://github.com/oatpp/oatpp-openssl.git")
    add_versions("1.3.0", "5925e8ba856fa71cda8937c4cb357508d4fdb3fb")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    add_deps("oatpp")
    add_deps("openssl")

    on_load(function (package)
        package:add("includedirs", path.join("include", "oatpp-" .. package:version_str(), "oatpp-openssl"))
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
            #include "oatpp-openssl/SHA1.hpp"
            void test() {
                oatpp::String message = "oat++ web framework";
                oatpp::String messageEncoded = "43e1bad62b6b4a1e88c9de60435335b5b7518f4a";
                {
                    oatpp::openssl::SHA1 sha;
                    sha.update(message);
                    oatpp::String encoded = sha.finalBinary();
                    OATPP_ASSERT(encoded == messageEncoded);
                }
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
