package("opentelemetry-cpp")
    set_homepage("https://opentelemetry.io/")
    set_description("OpenTelemetry is a collection of tools, APIs, and SDKs. Use it to instrument, generate, collect, and export telemetry data (metrics, logs, and traces) to help you analyze your software’s performance and behavior.")
    set_license("Apache-2.0")

    add_urls("https://github.com/open-telemetry/opentelemetry-cpp.git")
    add_versions("v1.16.1", "baecbb95bd63df53e0af16e87bc683967962c5f8")

    add_configs("pic", {description = "Position Independent Code.", default = false, type = "boolean"})
    add_configs("shared", {description = "Build shared libraries.", default = false, type = "boolean"})

    add_configs("withOtlpGrpc", {description = "Whether to include the OTLP gRPC exporter in the SDK.", default = false, type = "boolean"})
    add_configs("withOtlpHttp", {description = "Whether to include the OTLP http exporter in the SDK.", default = false, type = "boolean"})
    add_configs("withOtlpFile", {description = "Whether to include the OTLP file exporter in the SDK.", default = false, type = "boolean"})
    add_configs("withPrometheus", {description = "Enable building prometheus exporter.", default = false, type = "boolean"})
    add_configs("apiOnly", {description = "Only build the API (use as a header-only library). Overrides all options to enable exporters.", default = false, type = "boolean"})
    add_configs("withStl", {description = "Which version of the Standard Library for C++ to use. (ON, OFF, CXX11, CXX14, CXX17, CXX20 or CXX23)", default = "OFF", type = "string"})
    add_configs("withAbseil", {description = "Whether to use Abseil for C++latest features.", default = false, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        if package:config("withOtlpGrpc") then
            package:add("deps", "grpc")
        elseif package:config("withOtlpHttp") or package:config("withOtlpFile") then
            package:add("deps", "protobuf-cpp")
        elseif package:config("withAbseil") then
            package:add("deps", "abseil")
        end
        if package:config("withGsl") then
            package:add("deps", "gsl")
        end
    end)

    on_install(function (package)
        local configs = {
            "-DBUILD_TESTING=OFF",
            "-DWITH_EXAMPLES=OFF",
            "-DWITH_BENCHMARK=OFF",
            "-DWITH_FUNC_TESTS=OFF"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=" .. (package:config("pic") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_OTLP_GRPC=" .. (package:config("withOtlpGrpc") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_OTLP_HTTP=" .. (package:config("withOtlpHttp") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_OTLP_FILE=" .. (package:config("withOtlpFile") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_PROMETHEUS=" .. (package:config("withPrometheus") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_API_ONLY=" .. (package:config("apiOnly") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_STL=" .. package:config("withStl")) -- withStl is a string, see description
        local abseil = (package:config("withAbseil") or package:config("withOtlpGrpc") or package:config("withOtlpHttp") or package:config("withOtlpFile")) and "ON" or "OFF"
        table.insert(configs, "-DWITH_ABSEIL=" .. abseil)

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("opentelemetry::exporter::trace::OStreamSpanExporterFactory::Create()",{configs = {languages = "c++17"}, includes = "opentelemetry/exporters/ostream/span_exporter_factory.h"}))
    end)
