package("g3log")
    set_homepage("http://github.com/KjellKod/g3log")
    set_description("G3log is  an asynchronous, \"crash safe\", logger that is easy to use with default logging sinks or you can add your own.  G3log is made with plain C++14 (C++11 support up to release 1.3.2)  with no external libraries (except gtest used for unit tests). G3log is made to be cross-platform, currently running on OSX, Windows and several Linux distros.  See Readme below for details of usage.")

    add_urls("https://github.com/KjellKod/g3log/archive/refs/tags/$(version).tar.gz",
             "https://github.com/KjellKod/g3log.git")

    add_versions("2.3", "a27dc3ff0d962cc6e0b4e60890b4904e664b0df16393d27e14c878d7de09b505")

    add_configs("log_level", {description = "Turn ON/OFF log levels. An disabled level will not push logs of that level to the sink. By default dynamic logging is disabled", default = false, type = "boolean"})
    add_configs("debug_to_dbug", {description = "Use DBUG logging level instead of DEBUG. By default DEBUG is the debugging level", default = false, type = "boolean"})
    add_configs("funcsig", {description = "Windows __FUNCSIG__ to expand `Function` location of the LOG call instead of the default __FUNCTION__", default = false, type = "boolean"})
    add_configs("pretty_function", {description = "Windows __PRETTY_FUNCTION__ to expand `Function` location of the LOG call instead of the default __FUNCTION__", default = false, type = "boolean"})
    add_configs("dynamic_memory", {description = "Use dynamic memory for message buffer during log capturing", default = false, type = "boolean"})
    add_configs("full_filename", {description = "Log full filename", default = false, type = "boolean"})
    add_configs("fatal_signal_handling", {description = "Vectored exception / crash handling with improved stack trace", default = true, type = "boolean"})
    if is_plat("windows") then
        add_configs("vectored_exception_handling", {description = "Vectored exception / crash handling with improved stack trace", default = true, type = "boolean"})
    end

    if is_plat("windows") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_install(function (package)
        local configs =
        {
            "-DADD_FATAL_EXAMPLE=OFF",
            "-DADD_G3LOG_PERFORMANCE=OFF",
            "-DADD_G3LOG_UNIT_TEST=OFF",
            "-DINSTALL_G3LOG =ON",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DG3_SHARED_LIB=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DG3_IOS_LIB=" .. (package:is_plat("iphoneos") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_DYNAMIC_LOGGING_LEVELS=" .. (package:config("log_level") and "ON" or "OFF"))
        table.insert(configs, "-DCHANGE_G3LOG_DEBUG_TO_DBUG=" .. (package:config("debug_to_dbug") and "ON" or "OFF"))
        table.insert(configs, "-DWINDOWS_FUNCSIG=" .. (package:config("funcsig") and "ON" or "OFF"))
        table.insert(configs, "-DPRETTY_FUNCTION=" .. (package:config("pretty_function") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_G3_DYNAMIC_MAX_MESSAGE_SIZE=" .. (package:config("dynamic_memory") and "ON" or "OFF"))
        table.insert(configs, "-DG3_LOG_FULL_FILENAME=" .. (package:config("full_filename") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_FATAL_SIGNALHANDLING=" .. (package:config("fatal_signal_handling") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DG3_SHARED_RUNTIME=" .. (package:config("vs_runtime"):startswith("MD") and "ON" or "OFF"))
            table.insert(configs, "-DENABLE_VECTORED_EXCEPTIONHANDLING=" .. (package:config("vectored_exception_handling") and "ON" or "OFF"))
            table.insert(configs, "-DDEBUG_BREAK_AT_FATAL_SIGNAL=" .. (package:is_debug() and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <g3log/g3log.hpp>
            void test() {
                LOGF(INFO, "Hi log %d", 123);
                LOG_IF(INFO, (1 < 2)) << "If true this message will be logged";
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
