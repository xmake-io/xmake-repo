package("flatbuffers")
    set_homepage("http://google.github.io/flatbuffers/")
    set_description("FlatBuffers is a cross platform serialization library architected for maximum memory efficiency.")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/flatbuffers/archive/refs/tags/$(version).zip",
             "https://github.com/google/flatbuffers.git")

    add_versions("v1.12.0", "4b8b21adbfe8a74b90604161afcf87c125a26b86c99327e7a04525080606536c")
    add_versions("v2.0.0", "ffd68aebdfb300c9e82582ea38bf4aa9ce65c77344c94d5047f3be754cc756ea")
    add_versions("v23.1.21", "48597d6a6f8ca67a02ae8d8494b3bfc9136eb93da60a538d5bfc024f7c564f97")
    add_versions("v23.5.26", "57bd580c0772fd1a726c34ab8bf05325293bc5f9c165060a898afa1feeeb95e1")
    add_versions("v24.3.25", "e706f5eb6ca8f78e237bf3f7eccffa1c5ec9a96d3c1c938f08dc09aab1884528")

    add_deps("cmake")

    on_install(function(package)
        io.replace("CMakeLists.txt", "/MT", "", {plain = true})
        io.replace("CMakeLists.txt",
            "RUNTIME DESTINATION ${CMAKE_INSTALL_LIBDIR}",
            "RUNTIME DESTINATION bin", {plain = true})

        if not package:is_cross() then
            package:addenv("PATH", "bin")
        end

        local configs = {"-DFLATBUFFERS_BUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DFLATBUFFERS_BUILD_SHAREDLIB=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DFLATBUFFERS_BUILD_FLATLIB=" .. (package:config("shared") and "OFF" or "ON"))
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end

        table.insert(configs, "-DFLATBUFFERS_BUILD_FLATC=" .. (package:is_cross() and "OFF" or "ON"))
        table.insert(configs, "-DFLATBUFFERS_BUILD_FLATHASH=" .. (package:is_cross() and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") and package:is_debug() then
            os.trymv(package:installdir("lib/flatc.pdb"), package:installdir("bin"))
        end
    end)

    on_test(function(package)
        if not package:is_cross() then
            os.vrun("flatc --version")
        end
        assert(package:check_cxxsnippets({test = [[
            void test() {
                flatbuffers::FlatBufferBuilder builder;
                builder.CreateString("MyMonster");
                flatbuffers::DetachedBuffer dtbuilder = builder.Release();
            }
        ]]}, {configs = {languages = "c++14"}, includes = "flatbuffers/flatbuffers.h"}))
    end)
