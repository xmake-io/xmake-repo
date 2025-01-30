package("protobuf-cpp")
    set_homepage("https://developers.google.com/protocol-buffers/")
    set_description("Google's data interchange format for cpp")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/protocolbuffers/protobuf.git")
    add_urls("https://github.com/protocolbuffers/protobuf/releases/download/v$(version)", {version = function (version)
        if version:le("3.19.4") then
            return version .. "/protobuf-cpp-" .. version .. ".zip"
        else
            return version .. "/protobuf-" .. version .. ".zip"
        end
    end})

    -- TODO: Use x.y.z version? https://protobuf.dev/support/version-support
    add_versions("29.3", "e9b9ac1910b1041065839850603caf36e29d3d3d230ddf52bd13778dd31b9046")
    add_versions("29.2", "60c1ab4befe9d0a975c2344b5511bf6b44f91ec3e1426c878f56bf30a0589c43")
    add_versions("28.1", "0ac35978514f3e868181ea60237e695d892d4748ac03fb926a26ac7e2698aa29")
    add_versions("28.0", "979027233837dceaf927402e789261e46d4ff87ce45b3e38be8b15c4a1f696a3")
    add_versions("27.3", "a49147217f69e8d19aab0cc5c0059d6201261f5cb62145f8ab4ac8b94e7ffa86")
    add_versions("27.2", "7b4554f730a41f5c595cef3502038a69b8954c30d8ec9c62a167d5e1ebd8c210")
    add_versions("27.0", "3e1148db090ff21226c1888ef39fa7bc7790042be21ff4289fd21ce1735f3455")
    add_versions("26.1", "e15c272392df84ae95797759c685a9225fe5e88838bab3e0650c29239bdfccdd")
    add_versions("3.8.0", "91ea92a8c37825bd502d96af9054064694899c5c7ecea21b8d11b1b5e7e993b5")
	add_versions("3.12.0", "da826a3c48a9cae879928202d6fe06afb15aaee129e9035d6510cc776ddfa925")
    add_versions("3.12.3", "74da289e0d0c24b2cb097f30fdc09fa30754175fd5ebb34fae4032c6d95d4ce3")
    add_versions("3.13.0", "f7b99f47822b0363175a6751ab59ccaa4ee980bf1198f11a4c3cef162698dde3")
    add_versions("3.14.0", "87d6e96166cf5cafc16f2bcfa91c0b54f48bab38538285bee1b9331d992569fa")
    add_versions("3.15.5", "cdd7d3925240af541a95a4361ab100b703bee3a9df0d7e9e05c069cf2c76a039")
    add_versions("3.15.8", "093e0dca5277b377c36a48a3633325dca3d92d68ac17d5700a1f7e1c3eca2793")
    add_versions("3.17.3", "fe65f4bfbd6cbb8c23de052f218cbe4ebfeb72c630847e0cca63eb27616c952a")
    add_versions("3.19.4", "a11a262a395f999f9dca83e195cc15b6c23b6d5e74133f8e3250ad0950485da1")

    add_patches("3.17.3", path.join(os.scriptdir(), "patches", "3.17.3", "field_access_listener.patch"), "ac9bdf49611b01e563fe74b2aaf1398214129454c3e18f1198245549eb281e85")
    add_patches("3.19.4", path.join(os.scriptdir(), "patches", "3.19.4", "vs_runtime.patch"), "8e73e585d29f3b9dca3c279df0b11b3ee7651728c07f51381a69e5899b93c367")

    add_configs("rtti", {description = "Enable runtime type information", default = true, type = "boolean"})
    add_configs("zlib", {description = "Enable zlib", default = false, type = "boolean"})
    add_configs("lite", {description = "Build lite version", default = true, type = "boolean", readonly = true})
    add_configs("upb", {description = "Build upb", default = false, type = "boolean"})

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::protobuf")
    elseif is_plat("linux") then
        add_extsources("pacman::protobuf")
    elseif is_plat("macosx") then
        add_extsources("brew::protobuf")
    end

    add_deps("cmake")

    on_load(function (package)
        if package:is_plat("android") and is_host("windows") then
            package:add("deps", "ninja")
            package:set("policy", "package.cmake_generator.ninja", true)
        end

        if package:is_plat("windows") then
            package:add("links", "libprotoc", "libprotobuf", "utf8_range", "utf8_validity")
        else
            package:add("links", "protoc", "protobuf", "utf8_range", "utf8_validity")
        end

        if package:is_plat("linux", "bsd", "mingw") then
            package:add("syslinks", "m", "pthread")
        end

        if package:is_plat("linux") then
            if package:is_binary() then
                package:add("extsources", "apt::protobuf-compiler")
            elseif package:is_library() then
                package:add("extsources", "apt::libprotobuf-dev", "apt::libprotoc-dev")
            end
        end

        if not package:is_cross() then
            package:addenv("PATH", "bin")
        end

        if package:config("zlib") then
            package:add("deps", "zlib")
        end
        if package:version():ge("22.0") then
            package:add("deps", "abseil")
        end

        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "PROTOBUF_USE_DLLS")
        end
    end)
    -- ref: https://github.com/conan-io/conan-center-index/blob/19c9de61cce5a5089ce42b0cf15a88ade7763275/recipes/protobuf/all/conanfile.py
    on_component("utf8_range", function (package, component)
        component:add("extsources", "pkgconfig::utf8_range")
        component:add("links", "utf8_validity", "utf8_range")
    end)

    on_component("protobuf", function (package, component)
        component:add("extsources", "pkgconfig::protobuf")
        if is_plat("windows") then
            component:add("links", "libprotobuf", "utf8_validity")
        else
            component:add("links", "protobuf", "utf8_validity")
        end
    end)

    on_component("protobuf-lite", function (package, component)
        component:add("extsources", "pkgconfig::protobuf-lite")
        if is_plat("windows") then
            component:add("links", "libprotobuf-lite", "utf8_validity")
        else
            component:add("links", "protobuf-lite", "utf8_validity")
        end
    end)

    on_component("protoc", function (package, component)
        component:add("deps", "protobuf")
        if is_plat("windows") then
            component:add("links", "libprotoc")
        else
            component:add("links", "protoc")
        end
    end)

    on_component("upb", function (package, component)
        if is_plat("windows") then
            component:add("links", "libupb", "utf8_range")
        else
            component:add("links", "upb", "utf8_range")
        end
    end)

    on_install(function (package)
        if package:is_plat("windows", "mingw") then
            io.replace("src/google/protobuf/port_def.inc", "#define PROTOBUF_DESCRIPTOR_WEAK_MESSAGES_ALLOWED", "", {plain = true})
        end

        local version = package:version()
        if version:le("3.19.4") then
            os.cd("cmake")
        end
        io.replace("CMakeLists.txt", "set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreaded$<$<CONFIG:Debug>:Debug>)", "", {plain = true})
        io.replace("CMakeLists.txt", "set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreaded$<$<CONFIG:Debug>:Debug>DLL)", "", {plain = true})
        io.replace("CMakeLists.txt", "set(CMAKE_PDB_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)", "", {plain = true})
        if version:ge("26.1") then
            io.replace("cmake/abseil-cpp.cmake", "BUILD_SHARED_LIBS AND MSVC", "FALSE", {plain = true})
        end

        local configs = {
            "-Dprotobuf_BUILD_TESTS=OFF",
            "-Dprotobuf_LOCAL_DEPENDENCIES_ONLY=ON",
            "-Dprotobuf_BUILD_PROTOC_BINARIES=ON",
            "-Dprotobuf_DEBUG_POSTFIX=''",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-Dprotobuf_DISABLE_RTTI=" .. (package:config("rtti") and "OFF" or "ON"))
        if package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY=''")
            table.insert(configs, "-Dprotobuf_MSVC_STATIC_RUNTIME=" .. (package:has_runtime("MT", "MTd") and "ON" or "OFF"))
        end

        table.insert(configs, "-Dprotobuf_WITH_ZLIB=" .. (package:config("zlib") and "ON" or "OFF"))
        table.insert(configs, "-Dprotobuf_BUILD_LIBUPB=" .. (package:config("upb") and "ON" or "OFF"))

        local opt = {}
        opt.buildir = "build"
        if version:ge("22.0") then
            opt.packagedeps = "abseil"
            table.insert(configs, "-Dprotobuf_ABSL_PROVIDER=package")
        end
        import("package.tools.cmake").install(package, configs, opt)

        if package:is_cross() then
            os.tryrm(package:installdir("bin/*.exe"))
        else
            os.trycp("build/Release/protoc.exe", package:installdir("bin"))
        end
    end)

    on_test(function (package)
        if not package:is_cross() and
            -- Missing libgcc_s_xxx.dll, Maybe msys2 bug
            not (is_subhost("msys") and package:is_plat("mingw", "msys") and package:is_arch("i386")) then
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
        end
        if package:is_library() then
            assert(package:check_cxxsnippets({test = [[
                #include <google/protobuf/timestamp.pb.h>
                #include <google/protobuf/util/time_util.h>
                void test() {
                    google::protobuf::Timestamp ts;
                    google::protobuf::util::TimeUtil::FromString("1972-01-01T10:00:20.021Z", &ts);
                }
            ]]}, {configs = {languages = "c++17"}}))
        end
    end)
