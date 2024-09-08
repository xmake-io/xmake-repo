package("quill")
    set_homepage("https://github.com/odygrd/quill")
    set_description("Asynchronous Low Latency C++ Logging Library")
    set_license("MIT")

    set_urls("https://github.com/odygrd/quill/archive/refs/tags/$(version).tar.gz",
             "https://github.com/odygrd/quill.git")

    add_versions("v7.0.0", "15ad108b490ae6d605ed3ca78c149db832acddacb3846bec6d3a89fff2c063e2")
    add_versions("v6.1.2", "3eea9ec9634ce0ef28a2cc766d5316c1f068feb9340cf54e40e431a9342a9220")
    add_versions("v6.1.0", "3893ab422c746d93ff47bbcd61dd5e60bee37974b0d81cdab9cf9a4b10c58477")
    add_versions("v5.1.0", "0b4f34415c4b173f3d0466752fa3d3835e1a58f931bfce5281f817b5f997511f")
    add_versions("v5.0.0", "c2fd2b090db7d2d7633d4ee5a8316e43b4f5a13d8e339721b8e830fb03c25129")
    add_versions("v4.5.0", "70e8f4a76fd8a83b60d378f31b70dd09a9381686ebafdcd0db08fe099f518309")
    add_versions("v4.3.0", "c97bf3bfac6dfb7ed77fa08d945a490e302ba07e405539fda61985b39750cb29")
    add_versions("v3.8.0", "d3e1b349c5d6904c9644e5b79ec65f21692e8094a3d75241a7fe071076eef4dd")
    add_versions("v3.6.0", "ba9dc3df262f2e65c57904580cc8407eba9a462001340c17bab7ae1dccddb4bd")
    add_versions("v3.3.1", "f929d54a115b45c32dd2acd1a9810336d35c31fde9f5581c51ad2b80f980d0d1")
    add_versions("v2.9.0", "dec64c0fbb4bfbafe28fdeeeefac10206285bf2be4a42ec5dfb7987ca4ccb372")
    add_versions("v2.9.1", "921e053118136f63cebb2ca1d7e42456fd0bf9626facb755884709092753c054")
    add_versions("v2.8.0", "0461a6c314e3d882f3b9ada487ef1bf558925272509ee41a9fd25f7776db6075")

    add_patches("4.5.0", "patches/4.5.0/windows-arm.patch", "e7db1f07e1eea048798283f9865842c4754ed3d1ff220954cadd392ad4450cc3")

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
