package("fast-cdr")
    set_homepage("https://www.eprosima.com")
    set_description("eProsima FastCDR library provides two serialization mechanisms. One is the standard CDR serialization mechanism, while the other is a faster implementation of it.")
    set_license("Apache-2.0")

    add_urls("https://github.com/eProsima/Fast-CDR/archive/refs/tags/$(version).tar.gz",
             "https://github.com/eProsima/Fast-CDR.git")

    add_versions("v2.3.5", "e0af6cde06c4a43d90fa905c6d15721435520a26f0ba168ed13dfda45d164001")
    add_versions("v2.3.4", "5b96e85680bd105138202eb734e02545b3e0a06bff8eb55f1f06b692087ed9ef")
    add_versions("v2.3.3", "d48c33aca3ed805383f9a1c6210b6141a5e8044f260c831c1ca03be3a801fdb8")
    add_versions("v2.3.1", "a8703fa3209c7e33dcb6950447a5269dfd4f36d59d74e857bbbfffcdafd97d3f")
    add_versions("v2.3.0", "d85ee9e24e105581b49de3e2b6b2585335a8dc98c4cabd288232fffc4b9b6a24")
    add_versions("v2.2.6", "1d987f54a62ec5987f1482ff20df30ec84ca46238c7be3bd1d50acabadca3a09")
    add_versions("v2.2.5", "b01fd34135e9be5183bb69f31fa5b74c53ba6eca30a5b21de0120d21ece22a51")
    add_versions("v2.2.4", "06d7c8e091a866475b32c0f63d20fe3d8a2d996d65b30387111efbc8e4c666e5")
    add_versions("v2.2.3", "2501ef0930727d3b3ac1819672a6df8631a58fbcf7f005947046c2de46e8da69")
    add_versions("v2.2.2", "ae8b78a23c2929f26813d791757d0ef63a5e47e00ccfd3482743af1e837d9556")
    add_versions("v2.2.1", "11079a534cda791a8fc28d93ecb518bbd3804c0d4e9ca340ab24dcc21ad69a04")
    add_versions("v2.1.3", "9a992cf20d8df727df1cd389cc36039c92bbe86762b2c17a479f4f59a499b1ea")
    add_versions("v1.1.0", "5c4b2ad5493abd30b9475b14856641a8944c98077a36bd0760c1d83c65216e67")

    add_deps("cmake")

    on_install("windows", "linux", "macosx", "bsd", "msys", "android", "iphoneos", "cross", "wasm", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        io.replace("include/fastcdr/eProsima_auto_link.h", "        #pragma \\\n    comment(lib, EPROSIMA_LIB_PREFIX EPROSIMA_STRINGIZE(EPROSIMA_LIB_NAME) EPROSIMA_LIB_DEBUG_TAG \"-\" EPROSIMA_STRINGIZE(FASTCDR_VERSION_MAJOR) \".\" EPROSIMA_STRINGIZE(FASTCDR_VERSION_MINOR) \".lib\")", "", {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <fastcdr/FastBuffer.h>
            void test() {
                auto buffer = eprosima::fastcdr::FastBuffer();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
