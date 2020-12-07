package("flatbuffers")

    set_homepage("http://google.github.io/flatbuffers/")
    set_description("FlatBuffers is a cross platform serialization library architected for maximum memory efficiency.")

    add_urls("https://github.com/google/flatbuffers/archive/v$(version).zip")
    add_versions("1.12.0", "4b8b21adbfe8a74b90604161afcf87c125a26b86c99327e7a04525080606536c")

    add_deps("cmake")
    on_install("windows", "linux", "macosx", "mingw", "android", "iphoneos", function(package)
        local configs = {"-DFLATBUFFERS_BUILD_TESTS=OFF"}
        if is_plat("android", "iphoneos") then
            table.insert(configs, "-DFLATBUFFERS_BUILD_FLATC=OFF")
            table.insert(configs, "-DFLATBUFFERS_BUILD_FLATHASH=OFF")
        end
        import("package.tools.cmake").install(package, configs)
        package:addenv("PATH", "bin")
    end)

    on_test(function(package)
        if is_plat("windows", "linux", "macosx", "mingw") then
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
