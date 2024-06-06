package("quill")
    set_homepage("https://github.com/odygrd/quill")
    set_description("Asynchronous Low Latency C++ Logging Library")
    set_license("MIT")

    set_urls("https://github.com/odygrd/quill/archive/refs/tags/$(version).tar.gz",
             "https://github.com/odygrd/quill.git")

    add_versions("v4.3.0", "c97bf3bfac6dfb7ed77fa08d945a490e302ba07e405539fda61985b39750cb29")
    add_versions("v3.8.0", "d3e1b349c5d6904c9644e5b79ec65f21692e8094a3d75241a7fe071076eef4dd")
    add_versions("v3.6.0", "ba9dc3df262f2e65c57904580cc8407eba9a462001340c17bab7ae1dccddb4bd")
    add_versions("v3.3.1", "f929d54a115b45c32dd2acd1a9810336d35c31fde9f5581c51ad2b80f980d0d1")
    add_versions("v2.9.0", "dec64c0fbb4bfbafe28fdeeeefac10206285bf2be4a42ec5dfb7987ca4ccb372")
    add_versions("v2.9.1", "921e053118136f63cebb2ca1d7e42456fd0bf9626facb755884709092753c054")
    add_versions("v2.8.0", "0461a6c314e3d882f3b9ada487ef1bf558925272509ee41a9fd25f7776db6075")

    if is_plat("macosx") then
        add_extsources("brew::quill")
    end

    add_configs("fmt_external", {description = "Use external fmt library instead of bundled.(deprecated after v4)", default = false, type = "boolean"})
    add_configs("noexcept", {description = "Build without exceptions with -fno-exceptions flag", default = false, type = "boolean"})
    if is_plat("mingw") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        if package:version() and package:version():ge("4.0.0") then
            package:set("kind", "library", {headeronly = true})
        else
            if package:config("fmt_external") then
                package:add("deps", "fmt")
                package:add("defines", "QUILL_FMT_EXTERNAL")
            end
        end
    end)

    on_install("windows", "linux", "macosx", "mingw", function (package)
        local configs = {"-DQUILL_ENABLE_INSTALL=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DQUILL_NO_EXCEPTIONS=" .. (package:config("noexcept") and "ON" or "OFF"))
        if package:version() and package:version():lt("4.0.0") then
            if package:config("shared") and package:is_plat("windows") then
                table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
            end
            if package:config("fmt_external") then
                table.insert(configs, "-DQUILL_FMT_EXTERNAL=ON")
            end
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        local code = [[
            #include <quill/Quill.h>

            void test() {
                quill::Config cfg;
                cfg.enable_console_colours = true;
                quill::configure(cfg);
                quill::start();

                quill::Logger* logger = quill::get_logger();
                logger->set_log_level(quill::LogLevel::TraceL3);

                logger->init_backtrace(2, quill::LogLevel::Critical);
            }
        ]]
        if package:version() and package:version():ge("4.0.0") then
            code = [[
                #include "quill/Backend.h"
                #include "quill/Frontend.h"
                #include "quill/LogMacros.h"
                #include "quill/Logger.h"
                #include "quill/sinks/ConsoleSink.h"

                void test() 
                {
                    quill::Backend::start();
                    auto console_sink = quill::Frontend::create_or_get_sink<quill::ConsoleSink>("sink_id_1");
                    quill::Logger* logger = quill::Frontend::create_or_get_logger("root", std::move(console_sink));
                    LOG_INFO(logger, "This is a log info example {}", 123);
                }
            ]]
        end
        assert(package:check_cxxsnippets({test = code}, {configs = {languages = "c++17"}}))
    end)
