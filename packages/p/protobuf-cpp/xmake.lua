package("protobuf-cpp")

    set_homepage("https://developers.google.com/protocol-buffers/")
    set_description("Google's data interchange format for cpp")

    add_urls("https://github.com/protocolbuffers/protobuf/releases/download/v$(version)/protobuf-cpp-$(version).zip")
    add_versions("3.8.0", "91ea92a8c37825bd502d96af9054064694899c5c7ecea21b8d11b1b5e7e993b5")
    add_versions("3.12.3", "74da289e0d0c24b2cb097f30fdc09fa30754175fd5ebb34fae4032c6d95d4ce3")
    add_versions("3.13.0", "f7b99f47822b0363175a6751ab59ccaa4ee980bf1198f11a4c3cef162698dde3")
    add_versions("3.14.0", "87d6e96166cf5cafc16f2bcfa91c0b54f48bab38538285bee1b9331d992569fa")
    add_versions("3.15.5", "cdd7d3925240af541a95a4361ab100b703bee3a9df0d7e9e05c069cf2c76a039")
    add_versions("3.15.8", "093e0dca5277b377c36a48a3633325dca3d92d68ac17d5700a1f7e1c3eca2793")
    add_versions("3.17.3", "fe65f4bfbd6cbb8c23de052f218cbe4ebfeb72c630847e0cca63eb27616c952a")
    add_versions("3.19.4", "a11a262a395f999f9dca83e195cc15b6c23b6d5e74133f8e3250ad0950485da1")

    add_patches("3.17.3", path.join(os.scriptdir(), "patches", "3.17.3", "field_access_listener.patch"), "ac9bdf49611b01e563fe74b2aaf1398214129454c3e18f1198245549eb281e85")
    add_patches("3.19.4", path.join(os.scriptdir(), "patches", "3.19.4", "vs_runtime.patch"), "8e73e585d29f3b9dca3c279df0b11b3ee7651728c07f51381a69e5899b93c367")

    add_configs("zlib", {description = "Enable zlib", default = false, type = "boolean"})

    add_deps("cmake")

    if is_plat("windows") then
        add_links("libprotobuf")
    else
        add_links("protobuf")
    end

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        package:addenv("PATH", "bin")
        if package:config("zlib") then
            package:add("deps", "zlib")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        os.cd("cmake")
        io.replace("CMakeLists.txt", "set(protobuf_DEBUG_POSTFIX \"d\"", "set(protobuf_DEBUG_POSTFIX \"\"", {plain = true})
        local configs = {"-Dprotobuf_BUILD_TESTS=OFF", "-Dprotobuf_BUILD_PROTOC_BINARIES=ON"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-Dprotobuf_MSVC_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
            if package:config("shared") then
                package:add("defines", "PROTOBUF_USE_DLLS")
            end
        end
        if package:config("zlib") then
            table.insert(configs, "-Dprotobuf_WITH_ZLIB=ON")
        end
        import("package.tools.cmake").install(package, configs, {buildir = "build"})
        os.trycp("build/Release/protoc.exe", package:installdir("bin"))
    end)

    on_test(function (package)
        if package:is_cross() then
            return
        end
        io.writefile("test.proto", [[
            syntax = "proto3";
            package test;
            message TestCase {
                string name = 4;
            }
            message Test {
                repeated TestCase case = 1;
            }
        ]])
        os.vrun("protoc test.proto --cpp_out=.")
        assert(package:check_cxxsnippets({test = io.readfile("test.pb.cc")}, {configs = {includedirs = {".", package:installdir("include")}, languages = "c++11"}}))
    end)
