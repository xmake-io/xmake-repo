package("soralog")
    set_homepage("https://github.com/xDimon/soralog")
    set_description("Fast and flexible C++ logger with low-overhead logging calls")
    set_license("Apache-2.0")

    add_urls("https://github.com/xDimon/soralog/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xDimon/soralog.git")

    add_versions("v0.4.0", "ac8657a1cbe34873032b30e24037a40abaf19a50523942dc97e248ed270197da")

    -- The syslog sink is built everywhere but on Windows, the Event Log sink on Windows only
    if is_plat("windows", "mingw") then
        add_links("configurator_yaml", "fallback_configurator", "soralog", "logging_system",
                  "sink_to_nowhere", "sink_to_console", "sink_to_file", "sink_to_eventlog", "multisink", "sink")
        add_syslinks("advapi32")
    else
        add_links("configurator_yaml", "fallback_configurator", "soralog", "logging_system",
                  "sink_to_nowhere", "sink_to_console", "sink_to_file", "sink_to_syslog", "multisink", "sink")
    end
    if is_plat("linux", "bsd", "cross") then
        add_syslinks("pthread")
    end

    add_deps("cmake")
    add_deps("fmt", "yaml-cpp")

    if on_check then
        on_check("mingw", function (package)
            assert(not package:is_arch("i386", "x86"), "package(soralog) unsupported on mingw/i386: package(fmt) does not support it")
        end)
    end

    on_install("linux", "macosx", "bsd", "cross", "windows", "mingw", function (package)
        local configs = {
            "-DPACKAGE_MANAGER=none",
            "-DBUILD_TESTS=OFF",
            "-DBUILD_BENCHMARKS=OFF",
            "-DEXAMPLES=OFF"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto configurator = std::make_shared<soralog::ConfiguratorFromYAML>(std::string("groups: []"));
                soralog::LoggingSystem system(configurator);
                auto result = system.configure();
            }
        ]]}, {configs = {languages = "c++20"}, includes = {"soralog/impl/configurator_from_yaml.hpp", "soralog/logging_system.hpp"}}))
    end)
