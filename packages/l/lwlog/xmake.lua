package("lwlog")
    set_homepage("https://github.com/ChristianPanov/lwlog")
    set_description("Very fast synchronous and asynchronous C++17 logging library")
    set_license("MIT")

    add_urls("https://github.com/ChristianPanov/lwlog/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ChristianPanov/lwlog.git")

    add_versions("v1.5.0", "1820842edf252235aa97a7c876cba5455fcec767a68ac7ca5b05b673269b9942")
    add_versions("v1.3.1", "63123ff25b15d46ad0a89d4c85dd7c22d63382b89ed251607b3cbd908698a6da")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_includedirs("include/src", "include/lwlog")

    add_deps("cmake")

    on_install(function (package)
        io.replace("CMakeLists.txt", "STATIC", "", {plain = true})
        io.replace("CMakeLists.txt",
            "target_link_libraries(lwlog_lib PRIVATE Threads::Threads)",
            "target_link_libraries(lwlog_lib PUBLIC Threads::Threads)", {plain = true})

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") and package:config("shared") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <lwlog.h>
            void test() {
                auto basic = std::make_shared<lwlog::basic_logger<lwlog::sinks::stdout_sink>>("CONSOLE");
                auto console = std::make_shared<lwlog::console_logger>("CONSOLE");
                auto file = std::make_shared<lwlog::file_logger>("FILE", "C:/Users/user/Desktop/LogFolder/LOGS.txt");
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
