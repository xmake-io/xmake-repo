package("bqlog")
    set_homepage("https://github.com/Tencent/BqLog")
    set_description("Maybe the world's fastest logging library, originating from the client of the top mobile game Honor of Kings, is lightweight, works on PC, mobile, and servers, supports C#, Java, and C++, and is well adapted to Unity and Unreal engines.")

    add_urls("https://github.com/Tencent/BqLog/archive/refs/tags/Release_$(version).tar.gz",
             "https://github.com/Tencent/BqLog.git")

    add_versions("1.4.4", "c32a8eae1f935a0dfc2d67e93b0d6cad6a0c551d65e72b10713da304ab33ee11")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("windows", "mingw") then
        add_syslinks("shell32")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    elseif is_plat("android") then
        add_syslinks("log", "android")
    elseif is_plat("iphoneos") then
        add_frameworks("Security", "UIKit")
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_TYPE=" .. (package:config("shared") and "dynamic_lib" or "static_lib"))

        local plat = package:plat()
        if package:is_plat("windows", "mingw") then
            plat = "win64"
        elseif package:is_plat("macosx") then
            plat = "mac"
        elseif package:is_plat("iphoneos") then
            plat = "ios"
        elseif not package:is_plat("android", "linux") then
            plat = "unix"
        end
        table.insert(configs, "-DTARGET_PLATFORM=" .. plat)

        io.writefile("CMakeLists.txt", [[
            add_subdirectory(src)
            include(GNUInstallDirs)
            install(TARGETS BqLog
                RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
                LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
                ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
            )
            install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
        ]])
        io.replace("src/CMakeLists.txt", "/WX", "", {plain = true})
        io.replace("src/CMakeLists.txt", "-Werror", "", {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <string>
            void test() {
                std::string config;
                auto log = bq::log::create_log("my_first_log", config);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "bq_log/bq_log.h"}))
    end)
