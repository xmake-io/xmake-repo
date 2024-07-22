package("oatpp-zlib")
    set_homepage("https://oatpp.io/")
    set_description("It provides functionality for compressing/decompressing for oatpp applications.")
    set_license("Apache-2.0")

    add_urls("https://github.com/oatpp/oatpp-zlib/archive/$(version).tar.gz",
             "https://github.com/oatpp/oatpp-zlib.git")
    add_versions("1.3.0", "33a831eb42c9f56e6cd941ad23c3f7b6b2a1d8d7")
    add_versions("1.4.0", "c26ff2c92b9c2abb359458cebe126202fa9a706a")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    add_deps("oatpp")
    add_deps("zlib")

    on_load(function (package)
        package:add("includedirs", path.join("include", "oatpp-" .. package:version_str(), "oatpp-zlib"))
        package:add("linkdirs", path.join("lib", "oatpp-" .. package:version_str()))
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
            #include "oatpp-zlib/Processor.hpp"
            void test() {
                oatpp::zlib::DeflateEncoder encoder(1, true);
                oatpp::zlib::DeflateDecoder decoder(1, true);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
