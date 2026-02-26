package("opentelemetry-cpp")
    set_homepage("https://opentelemetry.io/")
    set_description("OpenTelemetry is a collection of tools, APIs, and SDKs. Use it to instrument, generate, collect, and export telemetry data (metrics, logs, and traces) to help you analyze your software’s performance and behavior.")
    set_license("Apache-2.0")

    add_urls("https://github.com/open-telemetry/opentelemetry-cpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/open-telemetry/opentelemetry-cpp.git", {submodules = false})

    add_versions("v1.25.0", "a0c944a9de981fe1874b31d1fe44b830fc30ee030efa27ee23fc73012a3a13e9")
    add_versions("v1.24.0", "7b8e966affca1daf1906272f4d983631cad85fb6ea60fb6f55dcd1811a730604")
    add_versions("v1.23.0", "148ef298a4ef9e016228d53d7208ab9359d4fdf87f55649d60d07ffacc093b33")
    add_versions("v1.22.0", "3428f433f4b435ed1fad64cbdbe75b7288c06f6297786a7036d65d5b9a1d215b")
    add_versions("v1.21.0", "98e5546f577a11b52a57faed1f4cc60d8c1daa44760eba393f43eab5a8ec46a2")
    add_versions("v1.19.0", "e0330194b72f2fe4c0ce3ece06b02dc4aa0ab491eb75bf42c6f5e283912e468c")
    add_versions("v1.16.1", "b8a78bb2a3a78133dbb08bcd04342f4b1e03cb4a19079b8416d408d905fffc37")

    add_configs("abseil", {description = "Whether to use Abseil for C++latest features. (not supported for >= v1.21.0)", default = false, type = "boolean"})
    add_configs("api_only", {description = "Only build the API (use as a header-only library). Overrides all options to enable exporters.", default = false, type = "boolean"})
    add_configs("cxx_standard", {description = "Select c++ standard to build.", default = "23", type = "string", values = {"11", "14", "17", "20", "23", "26"}})
    add_configs("otlp_grpc", {description = "Whether to include the OTLP gRPC exporter in the SDK.", default = false, type = "boolean"})
    add_configs("otlp_http", {description = "Whether to include the OTLP http exporter in the SDK.", default = false, type = "boolean"})
    add_configs("otlp_file", {description = "Whether to include the OTLP file exporter in the SDK.", default = false, type = "boolean"})
    add_configs("prometheus", {description = "Enable building prometheus exporter.", default = false, type = "boolean"})
    add_configs("stl", {description = "Which version of the Standard Library for C++ to use. (true, false, cxx11, cxx14, cxx17, cxx20 or cxx23)", default = "false", type = "string", values = {"true", "false", "cxx11", "cxx14", "cxx17", "cxx20", "cxx23", "cxx26"}})

    if is_host("windows") then
        set_policy("platform.longpaths", true)
    end

    add_deps("cmake")
    add_deps("nlohmann_json", {configs = {cmake = true}})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_links(
        "opentelemetry_exporter_otlp_http_metric",
        "opentelemetry_exporter_otlp_http_log",
        "opentelemetry_exporter_otlp_http",
        "opentelemetry_exporter_otlp_http_client",
        "opentelemetry_exporter_otlp_grpc_log",
        "opentelemetry_exporter_otlp_grpc_metrics",
        "opentelemetry_exporter_otlp_grpc",
        "opentelemetry_exporter_otlp_grpc_client",
        "opentelemetry_exporter_otlp_file_metric",
        "opentelemetry_exporter_otlp_file_log",
        "opentelemetry_exporter_otlp_file",
        "opentelemetry_exporter_otlp_file_client",
        "opentelemetry_exporter_prometheus",
        "opentelemetry_exporter_ostream_logs",
        "opentelemetry_exporter_ostream_span",
        "opentelemetry_exporter_ostream_metrics",
        "opentelemetry_exporter_in_memory",
        "opentelemetry_http_client_curl",
        "opentelemetry_proto_grpc",
        "opentelemetry_otlp_recordable",
        "opentelemetry_proto",
        "opentelemetry_logs",
        "opentelemetry_trace",
        "opentelemetry_metrics",
        "prometheus-cpp-pull",
        "prometheus-cpp-push",
        "prometheus-cpp-core",
        "opentelemetry_resources",
        "opentelemetry_common",
        "opentelemetry_version",
        "opentelemetry_cpp"
    )

    on_load(function (package)
        if package:config("api_only") then
            package:set("kind", "library", {headeronly = true})
        end

        if package:version() and package:version():ge("1.21.0") and package:config("abseil") then
             os.raise("abseil config is not supported for version >= 1.21.0")
        end

        if package:config("otlp_grpc") then
            package:add("deps", "grpc")
        elseif package:config("otlp_http") or package:config("otlp_file") then
            package:add("deps", "protobuf-cpp")
        elseif package:config("abseil") then
            package:add("deps", "abseil")
        end

        if package:config("otlp_http") then
            package:add("deps", "libcurl")
        end

        if package:config("shared") and package:is_plat("windows") then
            package:add("defines", "OPENTELEMETRY_BUILD_IMPORT_DLL")
        end
    
        local stl = package:config("stl")
        if stl ~= "false" then
            if stl ~= "true" then
                package:add("defines", "OPENTELEMETRY_STL_VERSION=20" .. stl:sub(4,5))
            else
                if package:version() and package:version():ge("1.16.1") and package:version():le("1.22.0") then
                    package:add("defines", "OPENTELEMETRY_STL_VERSION=2023")
                else
                    os.raise("Update version or define based on https://github.com/open-telemetry/opentelemetry-cpp/blob/main/api/CMakeLists.txt")
                end
            end
        end
    end)

    on_install("!iphoneos and !cross|!aarch64", function (package)
        local configs = {
            "-DBUILD_TESTING=OFF",
            "-DWITH_EXAMPLES=OFF",
            "-DWITH_BENCHMARK=OFF",
            "-DWITH_FUNC_TESTS=OFF",
        }

        if package:dep("protobuf-cpp") then
            local std = package:dep("abseil"):config("cxx_standard")
            table.insert(configs, "-DCMAKE_CXX_STANDARD=" .. std)
            package:data_set("cxx_standard", std)
        else
            table.insert(configs, "-DCMAKE_CXX_STANDARD=" .. package:config("cxx_standard"))
            package:data_set("cxx_standard", package:config("cxx_standard"))
        end

        if package:has_tool("cxx", "clang", "clangxx", "emcc", "emxx") then
            package:add("cxxflags", "-Wno-missing-template-arg-list-after-template-kw")
            table.insert(configs, "-DCMAKE_CXX_FLAGS=-Wno-missing-template-arg-list-after-template-kw")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        if package:config("shared") then
            if package:is_plat("windows") then
                -- @see https://github.com/open-telemetry/opentelemetry-cpp/issues/2477
                table.insert(configs, "-DOPENTELEMETRY_BUILD_DLL=ON")
                table.insert(configs, "-DBUILD_SHARED_LIBS=OFF")
            else
                table.insert(configs, "-DBUILD_SHARED_LIBS=ON")
            end
        else
            table.insert(configs, "-DBUILD_SHARED_LIBS=OFF")
        end

        table.insert(configs, "-DWITH_OTLP_GRPC=" .. (package:config("otlp_grpc") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_OTLP_HTTP=" .. (package:config("otlp_http") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_OTLP_FILE=" .. (package:config("otlp_file") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_PROMETHEUS=" .. (package:config("prometheus") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_API_ONLY=" .. (package:config("api_only") and "ON" or "OFF"))
        local stl = package:config("stl")
        if stl == "true" then
            stl = "on"
        elseif stl == "false" then
            stl = "off"
        end
        stl = string.upper(stl)
        table.insert(configs, "-DWITH_STL=" .. stl)

        if package:version() and package:version():lt("1.21.0") then
            local abseil = (package:config("abseil") or package:config("otlp_grpc") or package:config("otlp_http") or package:config("otlp_file")) and "ON" or "OFF"
            table.insert(configs, "-DWITH_ABSEIL=" .. abseil)
        end

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        if package:config("api_only") then
            assert(package:has_cxxincludes("opentelemetry/version.h"))
        else
            assert(package:has_cxxfuncs("opentelemetry::exporter::trace::OStreamSpanExporterFactory::Create()", {configs = {languages = "c++" ..  package:data("cxx_standard")}, includes = "opentelemetry/exporters/ostream/span_exporter_factory.h"}))
        end
    end)
