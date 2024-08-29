package("opentelemetry-cpp")
    set_homepage("https://opentelemetry.io/")
    set_description("OpenTelemetry is a collection of tools, APIs, and SDKs. Use it to instrument, generate, collect, and export telemetry data (metrics, logs, and traces) to help you analyze your software’s performance and behavior.")
    set_license("Apache-2.0")

    add_urls("https://github.com/open-telemetry/opentelemetry-cpp.git")
    add_versions("v1.16.1", "baecbb95bd63df53e0af16e87bc683967962c5f8")

    add_configs("otlp_grpc", {description = "Whether to include the OTLP gRPC exporter in the SDK.", default = false, type = "boolean"})
    add_configs("otlp_http", {description = "Whether to include the OTLP http exporter in the SDK.", default = false, type = "boolean"})
    add_configs("otlp_file", {description = "Whether to include the OTLP file exporter in the SDK.", default = false, type = "boolean"})
    add_configs("prometheus", {description = "Enable building prometheus exporter.", default = false, type = "boolean"})
    add_configs("api_only", {description = "Only build the API (use as a header-only library). Overrides all options to enable exporters.", default = false, type = "boolean"})
    add_configs("stl", {description = "Which version of the Standard Library for C++ to use. (true, false, cxx11, cxx14, cxx17, cxx20 or cxx23)", default = "false", type = "string", values = {"true", "false", "cxx11", "cxx14", "cxx17", "cxx20", "cxx23"}})
    add_configs("abseil", {description = "Whether to use Abseil for C++latest features.", default = false, type = "boolean"})

    if is_host("windows") then
        set_policy("platform.longpaths", true)
    end

    add_deps("cmake")

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
        if package:config("otlp_grpc") then
            package:add("deps", "grpc")
        elseif package:config("otlp_http") or package:config("otlp_file") then
            package:add("deps", "protobuf-cpp")
        elseif package:config("abseil") then
            package:add("deps", "abseil")
        end
        if package:config("shared") and package:is_plat("windows") then
            package:add("defines", "OPENTELEMETRY_BUILD_IMPORT_DLL")
        end
    end)

    on_install("!iphoneos and !cross|!aarch64", function (package)
        local configs = {
            "-DBUILD_TESTING=OFF",
            "-DWITH_EXAMPLES=OFF",
            "-DWITH_BENCHMARK=OFF",
            "-DWITH_FUNC_TESTS=OFF",
            "-DCMAKE_CXX_STANDARD=14"
        }
        if package:has_tool("cxx", "clang", "clangxx", "emcc", "emxx") then
            package:add("cxxflags", "-Wno-missing-template-arg-list-after-template-kw")
            table.insert(configs, "-DCMAKE_CXX_FLAGS=-Wno-missing-template-arg-list-after-template-kw")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=" .. (package:config("pic") and "ON" or "OFF"))
        if package:config("shared") then
            if package:is_plat("windows") then
                table.insert(configs, "-DOPENTELEMETRY_BUILD_DLL=ON")
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
        local abseil = (package:config("abseil") or package:config("otlp_grpc") or package:config("otlp_http") or package:config("otlp_file")) and "ON" or "OFF"
        table.insert(configs, "-DWITH_ABSEIL=" .. abseil)

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("opentelemetry::exporter::trace::OStreamSpanExporterFactory::Create()", {configs = {languages = "c++17"}, includes = "opentelemetry/exporters/ostream/span_exporter_factory.h"}))
    end)
