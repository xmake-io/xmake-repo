package("oatpp")
    set_homepage("https://oatpp.io/")
    set_description("Modern Web Framework for C++. High performance, simple API, cross platform, zero dependency.")
    set_license("Apache-2.0")

    add_urls("https://github.com/oatpp/oatpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/oatpp/oatpp.git")

    add_versions("1.0.0", "9ba7c75e3ada8ec894ec10beae712e775774a835fd3de89d8c34e17740202619")
    add_versions("1.2.5", "36276e8b23e68ece1e6093c3f06fc80e3d42a5f4e47cdeef5e7e63f36eeddaad")
    add_versions("1.3.0", "e1f80fa8fd7a74da6737e7fee1a4db68b4d7085a3f40e7d550752d6ff5714583")
    add_versions("1.4.0-preview", "bbf9715eb8bc3ef58686c5b1fb844de4b73ba6d0")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("windows") then
        add_syslinks("ws2_32")
    end

    add_deps("cmake")

    on_load(function (package)
        local version = package:version_str():gsub("-preview", "")
        package:add("includedirs", path.join("include", "oatpp-" .. version, "oatpp"))
        package:add("linkdirs", path.join("lib", "oatpp-" .. version))
    end)

    on_install("linux", "macosx", "windows|x64", function (package)
        local configs = {"-DOATPP_BUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DOATPP_MSVC_LINK_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "oatpp/encoding/Base64.hpp"
            #include "oatpp/base/Log.hpp"
            void test() {
                oatpp::String message = "oat++ web framework";
                oatpp::String messageEncoded = "b2F0Kysgd2ViIGZyYW1ld29yaw==";
                {
                    oatpp::String encoded = oatpp::encoding::Base64::encode(message);
                    OATPP_ASSERT(encoded == messageEncoded);
                    oatpp::String decoded = oatpp::encoding::Base64::decode(encoded);
                    OATPP_ASSERT(message == decoded);
                }
            }
        ]]}, {configs = {languages = "cxx11"}}))
    end)
