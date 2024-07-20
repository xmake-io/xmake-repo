package("oatpp-zlib")
    set_homepage("https://oatpp.io/")
    set_description("It provides functionality for compressing/decompressing for oatpp applications.")
    set_license("Apache-2.0")

    add_urls("https://github.com/oatpp/oatpp-zlib/archive/$(version).tar.gz",
             "https://github.com/oatpp/oatpp-zlib.git")
    add_versions("1.3.0", "33a831eb42c9f56e6cd941ad23c3f7b6b2a1d8d7")

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
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DOATPP_MSVC_LINK_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "oatpp-zlib/Processor.hpp"
            #include "oatpp/core/utils/Random.hpp"
            #include "oatpp/core/data/stream/BufferStream.hpp"
            void test() {
                for (v_int32 e = 1; e <= 64; e++) {
                    for (v_int32 d = 1; d <= 64; d++) {

                    oatpp::String original(1024);
                    oatpp::utils::random::Random::randomBytes((p_char8)original->data(), original->size());

                    oatpp::data::buffer::IOBuffer buffer;

                    oatpp::data::stream::BufferInputStream inStream(original);
                    oatpp::data::stream::BufferOutputStream outEncoded;

                    oatpp::zlib::DeflateEncoder encoder(e, true);

                    oatpp::data::stream::transfer(&inStream, &outEncoded, 0, buffer.getData(), buffer.getSize(), &encoder);

                    oatpp::data::stream::BufferInputStream inEncoded(outEncoded.toString());
                    oatpp::data::stream::BufferOutputStream outStream;

                    oatpp::zlib::DeflateDecoder decoder(d, true);

                    oatpp::data::stream::transfer(&inEncoded, &outStream, 0, buffer.getData(), buffer.getSize(), &decoder);

                    auto check = outStream.toString();

                    if (check != original) {
                        OATPP_LOGD("TEST", "Error. e=%d, d=%d", e, d);
                    }

                    OATPP_ASSERT(check == original);

                    }
                }
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
