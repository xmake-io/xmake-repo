package("quill")

    set_homepage("https://github.com/odygrd/quill")
    set_description("Asynchronous Low Latency C++ Logging Library")

    set_urls("https://github.com/odygrd/quill/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/odygrd/quill.git")

    add_versions("2.8.0", "0461a6c314e3d882f3b9ada487ef1bf558925272509ee41a9fd25f7776db6075")
    add_versions("2.9.0", "dec64c0fbb4bfbafe28fdeeeefac10206285bf2be4a42ec5dfb7987ca4ccb372")
    add_versions("2.9.1", "921e053118136f63cebb2ca1d7e42456fd0bf9626facb755884709092753c054")

    if is_plat("macosx") then
        add_extsources("brew::quill")
    end

    add_configs("fmt_external", {description = "Use external fmt library instead of bundled.", default = false, type = "boolean"})
    add_configs("noexcept", {description = "Build without exceptions with -fno-exceptions flag", default = false, type = "boolean"})
    if is_plat("mingw") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        if package:config("fmt_external") then
            package:add("deps", "fmt")
            package:add("defines", "QUILL_FMT_EXTERNAL")
        end
    end)

    on_install("windows", "linux", "macosx", "mingw", function (package)
        local configs = {"-DQUILL_ENABLE_INSTALL=ON"}
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        if package:config("fmt_external") then
            table.insert(configs, "-DQUILL_FMT_EXTERNAL=ON")
        end
        if package:config("noexcept") then
            table.insert(configs, "-DQUILL_NO_EXCEPTIONS=ON")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
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
        ]]}, {configs = {languages = "c++17"}}))
    end)
