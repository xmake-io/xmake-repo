package("flatbuffers")
    set_homepage("http://google.github.io/flatbuffers/")
    set_description("FlatBuffers is a cross platform serialization library architected for maximum memory efficiency.")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/flatbuffers/archive/refs/tags/$(version).zip",
             "https://github.com/google/flatbuffers.git")

    add_versions("v25.12.19", "f5d4636bfc4d30c622c9ad238ce947848c2b90b10aecd387dc62cdee2584359b")
    add_versions("v25.9.23", "083a424984986ba7fcd1635d54417d4523a3c729e137575db2421e996a1fb816")
    add_versions("v1.12.0", "4b8b21adbfe8a74b90604161afcf87c125a26b86c99327e7a04525080606536c")
    add_versions("v2.0.0", "ffd68aebdfb300c9e82582ea38bf4aa9ce65c77344c94d5047f3be754cc756ea")
    add_versions("v23.1.21", "48597d6a6f8ca67a02ae8d8494b3bfc9136eb93da60a538d5bfc024f7c564f97")
    add_versions("v23.5.26", "57bd580c0772fd1a726c34ab8bf05325293bc5f9c165060a898afa1feeeb95e1")
    add_versions("v24.3.25", "e706f5eb6ca8f78e237bf3f7eccffa1c5ec9a96d3c1c938f08dc09aab1884528")
    add_versions("v24.12.23", "c5cd6a605ff20350c7faa19d8eeb599df6117ea4aabd16ac58a7eb5ba82df4e7")
    add_versions("v25.2.10", "75ffbce7d32f8218b5faec86ae2f6397c7ca810605dc710dfa9c146b9df9e3e9")

    add_deps("cmake")

    on_install(function(package)
        if not package:is_cross() then
            package:addenv("PATH", "bin")
        end

        io.replace("CMakeLists.txt", "/MT", "", {plain = true})
        io.replace("CMakeLists.txt",
            "RUNTIME DESTINATION ${CMAKE_INSTALL_LIBDIR}",
            "RUNTIME DESTINATION bin", {plain = true})

        local configs = {"-DFLATBUFFERS_BUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        if package:is_binary() then
            table.insert(configs, "-DFLATBUFFERS_BUILD_SHAREDLIB=OFF")
            table.insert(configs, "-DFLATBUFFERS_BUILD_FLATLIB=OFF")
        else
            table.insert(configs, "-DFLATBUFFERS_BUILD_SHAREDLIB=" .. (package:config("shared") and "ON" or "OFF"))
            table.insert(configs, "-DFLATBUFFERS_BUILD_FLATLIB=" .. (package:config("shared") and "OFF" or "ON"))
        end
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end

        table.insert(configs, "-DFLATBUFFERS_BUILD_FLATC=" .. (package:is_cross() and "OFF" or "ON"))
        table.insert(configs, "-DFLATBUFFERS_BUILD_FLATHASH=" .. (package:is_cross() and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)

        if package:is_binary() then
            os.tryrm(package:installdir("include"))
        end
    end)

    on_test(function(package)
        if not package:is_cross() then
            os.vrun("flatc --version")
        end
        if package:is_library() then
            assert(package:check_cxxsnippets({test = [[
                void test() {
                    flatbuffers::FlatBufferBuilder builder;
                    builder.CreateString("MyMonster");
                    flatbuffers::DetachedBuffer dtbuilder = builder.Release();
                }
            ]]}, {configs = {languages = "c++14"}, includes = "flatbuffers/flatbuffers.h"}))
        end
    end)
