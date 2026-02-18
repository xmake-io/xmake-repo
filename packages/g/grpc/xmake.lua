package("grpc")
    set_homepage("https://grpc.io")
    set_description("The C based gRPC (C++, Python, Ruby, Objective-C, PHP, C#)")
    set_license("Apache-2.0")

    add_urls("https://github.com/grpc/grpc/archive/refs/tags/$(version).zip",
             "https://github.com/grpc/grpc.git")

    add_versions("v1.74.0", "1f6ef5bb3cfaec416ef3c8cc19b26eb83c669f131400c2460671d50ff5784920")
    add_versions("v1.69.0", "987763312292c8a6088108173ccde2b336a40f35ae22b5b7b3744e44929aaf9f")
    add_versions("v1.51.3", "17720fd0a690e904a468b4b3dae6fa5ec40b0d1f4d418e2ca092e2f92f06fce0")
    add_versions("v1.62.1", "f672a3a3b370f2853869745110dabfb6c13af93e17ffad4676a0b95b5ec204af")
    add_versions("v1.68.2", "2a17adb0d23768413ca85990dbf800a600863d272fcc37a9f67f3b5e34ae9174")

    add_patches("1.68.2", path.join(os.scriptdir(), "patches", "1.68.2", "fix-nan-on-win11.patch"), "ebb7cb2772528edd9de306820a4f811f4e8150fa4daa4471431315bfa30a2617")
    add_patches("1.51.3", path.join(os.scriptdir(), "patches", "1.51.3", "disable-download-archive.patch"), "90fdd6e4a51cbc9756d1fcdd0f65e665d4b78cfd91fdbeb0228cc4e9c4ba1b73")
    add_patches("1.51.3", path.join(os.scriptdir(), "patches", "1.51.3", "static-linking-in-linux.patch"), "176474919883f93be0c5056098eccad408038663c6c7361f2e049cdf7247a19c")

    add_configs("openssl3", {description = "default use openssl3.", default = true, type = "boolean"})

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    add_deps("c-ares", "re2", "protobuf-cpp", "zlib")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "dl", "m")
    elseif is_plat("macosx", "iphoneos") then
        add_frameworks("CoreFoundation")
    end

    if on_check then
        on_check(function (package)
            if package:is_plat("mingw", "msys") then
                raise("package(grpc) unsupported mingw plat on msys.\nFix refer: https://github.com/msys2/MINGW-packages/tree/404359eedd188a8427ed139659472d64bd250384/mingw-w64-grpc")
            end
        end)
    end

    on_load(function (package)
        if package:config("openssl3") then
            package:add("deps", "openssl3")
        else
            package:add("deps", "openssl")
        end
        package:add("links", "grpc++", "grpc++_unsecure", "grpc++_alts", "grpc++_reflection", "grpc++_error_details", "grpcpp_channelz")
        package:add("links", "grpc", "grpc_unsecure", "grpc_plugin_support", "grpc_authorization_provider", "gpr")
        package:add("links", "address_sorting")
        if package:gitref() or package:version():ge("1.68.2") then
            package:add("links", "upb_textformat_lib", "upb_json_lib", "upb_wire_lib", "upb_message_lib", "utf8_range_lib", "upb_mini_descriptor_lib", "upb_mem_lib", "upb_base_lib")
        else
            package:add("links", "upb")
        end

        if not package:is_cross() then
            package:addenv("PATH", "bin")
        end
    end)

    on_install("!wasm", function (package)
        -- Fix ucrt
        io.replace("CMakeLists.txt", "include(cmake/msvc_static_runtime.cmake)", "", {plain = true})
        -- @see https://github.com/grpc/grpc/issues/36654#issuecomment-2228569158
        if package:is_plat("macosx") and package:config("shared") then
            io.replace("CMakeLists.txt", "target_compile_features(upb_textformat_lib PUBLIC cxx_std_14)",
            "target_compile_features(upb_textformat_lib PUBLIC cxx_std_14)\ntarget_link_options(upb_textformat_lib PRIVATE -Wl,-undefined,dynamic_lookup)\ntarget_link_options(upb_json_lib PRIVATE -Wl,-undefined,dynamic_lookup)", {plain = true})
        end
        if package:is_cross() then
            -- xrepo protobuf will remove protoc.exe in cross-compilation
            -- Avoid using CONFIG mode in cmake to find protoc.exe
            io.replace("cmake/protobuf.cmake", "find_package(Protobuf REQUIRED CONFIG)", "find_package(Protobuf)", {plain = true})
            -- Disable plugin build
            -- https://github.com/grpc/grpc/issues/29370
            io.replace("CMakeLists.txt", "add_library(grpc_plugin_support",
                "if(0)\nadd_library(grpc_plugin_support", {plain = true})
            io.replace("CMakeLists.txt", "if(gRPC_INSTALL)\n  install(TARGETS grpc_plugin_support",
                "endif()\nif(0)\n  install(TARGETS grpc_plugin_support", {plain = true})
        end

        local configs = {
            "-DgRPC_DOWNLOAD_ARCHIVES=OFF",
            "-DCMAKE_CXX_STANDARD=" .. package:dep("abseil"):config("cxx_standard"),
            "-DCMAKE_CXX_STANDARD_REQUIRED=TRUE",
            "-DgRPC_BUILD_TESTS=OFF",

            "-DgRPC_ZLIB_PROVIDER=package",
            "-DgRPC_ABSL_PROVIDER=package",
            "-DgRPC_CARES_PROVIDER=package",
            "-DgRPC_RE2_PROVIDER=package",
            "-DgRPC_SSL_PROVIDER=package",
            "-DgRPC_PROTOBUF_PROVIDER=package",
            "-DgRPC_PROTOBUF_PACKAGE_TYPE=CONFIG",
            "-DgRPC_UPB_PROVIDER=module",
            "-DgRPC_BENCHMARK_PROVIDER=none",
            "-DgRPC_USE_SYSTEMD=OFF", -- TODO: unbundle dep

            "-DgRPC_BUILD_GRPC_CSHARP_PLUGIN=OFF",
            "-DgRPC_BUILD_GRPC_NODE_PLUGIN=OFF",
            "-DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN=OFF",
            "-DgRPC_BUILD_GRPC_PHP_PLUGIN=OFF",
            "-DgRPC_BUILD_GRPC_PYTHON_PLUGIN=OFF",
            "-DgRPC_BUILD_GRPC_RUBY_PLUGIN=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        table.insert(configs, "-DgRPC_BUILD_CODEGEN=" .. (package:is_cross() and "OFF" or "ON"))
        table.insert(configs, "-DgRPC_BUILD_GRPC_CPP_PLUGIN=" .. (package:is_cross() and "OFF" or "ON"))

        local opt = {}
        if not (package:gitref() or package:version():ge("1.68.2")) then
            opt.packagedeps = "protobuf-cpp"
        end
        if package:is_binary() then
            opt.target = "grpc_cpp_plugin"
            import("package.tools.cmake").build(package, configs, opt)

            os.cp(path.join(package:buildir(), "grpc_cpp_plugin*"), package:installdir("bin"))
        else
            import("package.tools.cmake").install(package, configs, opt)
        end

    end)

    on_test(function (package)
        if not package:is_cross() then
            local grpc_cpp_plugin = "bin/grpc_cpp_plugin" .. (is_host("windows") and ".exe" or "")
            assert(os.isfile(path.join(package:installdir(), grpc_cpp_plugin)))
        end

        if package:is_library() then
            local languages = "c++" .. package:dep("abseil"):config("cxx_standard")
            assert(package:check_cxxsnippets({test = [[
                void test() {
                    auto v = grpc::Version();
                }
            ]]}, {configs = {languages = languages}, includes = "grpcpp/grpcpp.h"}))
        end
    end)
