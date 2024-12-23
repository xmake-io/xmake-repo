package("grpc")
    set_homepage("https://grpc.io")
    set_description("The C based gRPC (C++, Python, Ruby, Objective-C, PHP, C#)")
    set_license("Apache-2.0")

    add_urls("https://github.com/grpc/grpc/archive/refs/tags/$(version).zip",
             "https://github.com/grpc/grpc.git")

    add_versions("v1.51.3", "17720fd0a690e904a468b4b3dae6fa5ec40b0d1f4d418e2ca092e2f92f06fce0")
    add_versions("v1.62.1", "f672a3a3b370f2853869745110dabfb6c13af93e17ffad4676a0b95b5ec204af")
    add_versions("v1.68.2", "2a17adb0d23768413ca85990dbf800a600863d272fcc37a9f67f3b5e34ae9174")

    add_patches("1.68.2", path.join(os.scriptdir(), "patches", "1.68.2", "fix-nan-on-win11.patch"), "ebb7cb2772528edd9de306820a4f811f4e8150fa4daa4471431315bfa30a2617")
    add_patches("1.51.3", path.join(os.scriptdir(), "patches", "1.51.3", "disable-download-archive.patch"), "90fdd6e4a51cbc9756d1fcdd0f65e665d4b78cfd91fdbeb0228cc4e9c4ba1b73")
    add_patches("1.51.3", path.join(os.scriptdir(), "patches", "1.51.3", "static-linking-in-linux.patch"), "176474919883f93be0c5056098eccad408038663c6c7361f2e049cdf7247a19c")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    add_deps("c-ares", "re2", "protobuf-cpp", "openssl", "zlib")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "dl", "m")
    elseif is_plat("macosx", "iphoneos") then
        add_frameworks("CoreFoundation")
    end

    if on_check then
        on_check(function (package)
            if package:is_cross() then
                raise("package(grpc) unsupported cross-compilation")
            end
        end)
    end

    on_load(function (package)
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

    on_install("linux", "macosx", "windows", function (package)
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

        local opt = {}
        if not (package:gitref() or package:version():ge("1.68.2")) then
            opt.packagedeps = "protobuf-cpp"
        end
        import("package.tools.cmake").install(package, configs, opt)

        if package:is_cross() then
            os.tryrm(package:installdir("bin/*.exe"))
        end
    end)

    on_test(function (package)
        if not package:is_cross() then
            assert(os.isfile(path.join(package:installdir(), "bin", "grpc_cpp_plugin")))
        end

        local languages = "c++" .. package:dep("abseil"):config("cxx_standard")
        if package:is_library() then
            assert(package:check_cxxsnippets({test = [[
                void test() {
                    auto v = grpc::Version();
                }
            ]]}, {configs = {languages = languages}, includes = "grpcpp/grpcpp.h"}))
        end
    end)
