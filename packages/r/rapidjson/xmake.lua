package("rapidjson")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Tencent/rapidjson")
    set_description("RapidJSON is a JSON parser and generator for C++.")
    set_license("MIT")

    set_urls("https://github.com/Tencent/rapidjson.git")

    add_versions("v1.1.0", "8e00c38829d6785a2dfb951bb87c6974fa07dfe488aa5b25deec4b8bc0f6a3ab")
    add_versions("v1.1.0-arrow", "1a803826f1197b5e30703afe4b9c0e7dd48074f5")

    add_versions("git:2025.02.05", "24b5e7a8b27f42fa16b96fc70aade9106cf7102f")

    add_configs("cmake", {description = "Use cmake build system", default = false, type = "boolean"})

    on_load(function (package)
        if package:is_plat("windows") and package:is_arch("arm.*") then
            package:add("defines", "RAPIDJSON_ENDIAN=RAPIDJSON_LITTLEENDIAN")
        end
    end)

    on_install(function (package)
        if package:config("cmake") then
            package:add("deps", "cmake")
            local configs = {
                "-DRAPIDJSON_BUILD_DOC=OFF",
                "-DRAPIDJSON_BUILD_EXAMPLES=OFF",
                "-DRAPIDJSON_BUILD_TESTS=OFF",
                "-DRAPIDJSON_BUILD_THIRDPARTY_GTEST=OFF",
                "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release")
            }
            import("package.tools.cmake").install(package, configs)
        else
            os.cp("include/*", package:installdir("include"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                const char* json = "{\"project\":\"rapidjson\",\"stars\":10}";
                rapidjson::Document d;
                d.Parse(json);

                rapidjson::StringBuffer buffer;
                rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
                d.Accept(writer);
            }
        ]]}, {
            configs = {languages = "c++11"},
            includes = {
                "rapidjson/document.h",
                "rapidjson/stringbuffer.h",
                "rapidjson/writer.h"
            }
        }))
    end)
