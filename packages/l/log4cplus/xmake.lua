package("log4cplus")
    set_homepage("https://sourceforge.net/projects/log4cplus/")
    set_description("log4cplus is a simple to use C++ logging API providing thread-safe, flexible, and arbitrarily granular control over log management and configuration.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/log4cplus/log4cplus/releases/download/REL_$(version).tar.gz", {version = function (version) return version:gsub("%.", "_") .. "/log4cplus-" .. version end})
    add_versions("2.1.2", "e2673815ea34886f29b2213fff19cc1a6707a7e65099927a19ea49b4eb018822")
    add_versions("2.1.1", "42dc435928917fd2f847046c4a0c6086b2af23664d198c7fc1b982c0bfe600c1")
    add_versions("2.0.6", "5fb26433b0f200ebfc2e6effb7e2e5131185862a2ea9a621a8e7f3f725a72b08")
    add_versions("2.0.7", "086451c7e7c582862cbd6c60d87bb6d9d63c4b65321dba85fa71766382f7ec6d")

    add_configs("unicode", {description = "Use unicode charset.", default = true, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_syslinks("advapi32", "ws2_32")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_load(function (package)
        if package:config("unicode") then
            package:add("defines", "UNICODE")
        end
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "LOG4CPLUS_BUILD_DLL")
        end
    end)

    on_install(function (package)
        local configs = {
            "-DLOG4CPLUS_BUILD_TESTING=OFF",
            "-DWITH_UNIT_TESTS=OFF",
            "-DLOG4CPLUS_ENABLE_DECORATED_LIBRARY_NAME=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DUNICODE=" .. (package:config("unicode") and "ON" or "OFF"))
        if package:is_plat("wasm") then
            table.insert(configs, "-DLOG4CPLUS_BUILD_LOGGINGSERVER=OFF")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                log4cplus::Initializer initializer;
                log4cplus::BasicConfigurator config;
                config.configure();
                log4cplus::Logger logger = log4cplus::Logger::getInstance(LOG4CPLUS_TEXT("main"));
                LOG4CPLUS_WARN(logger, LOG4CPLUS_TEXT("Hello, World!"));
            }
        ]]}, {configs = {languages = "c++17"}, includes = "log4cplus/log4cplus.h"}))
    end)
