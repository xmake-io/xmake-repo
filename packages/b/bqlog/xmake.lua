package("bqlog")
    set_homepage("https://github.com/Tencent/BqLog")
    set_description("Maybe the world's fastest logging library, originating from the client of the top mobile game Honor of Kings, is lightweight, works on PC, mobile, and servers, supports C#, Java, and C++, and is well adapted to Unity and Unreal engines.")

    add_urls("https://github.com/Tencent/BqLog/archive/refs/tags/Release_$(version).tar.gz",
             "https://github.com/Tencent/BqLog.git")

    add_versions("1.4.4", "c32a8eae1f935a0dfc2d67e93b0d6cad6a0c551d65e72b10713da304ab33ee11")

    if is_plat("windows", "mingw") then
        add_syslinks("shell32")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    elseif is_plat("bsd") then
        add_syslinks("pthread", "execinfo")
    elseif is_plat("android") then
        add_syslinks("log", "android")
    elseif is_plat("iphoneos") then
        add_frameworks("Security", "UIKit")
    end

    add_deps("cmake")

    if on_check then
        on_check("windows", function (package)
            local vs_toolset = package:toolchain("msvc"):config("vs_toolset")
            if vs_toolset then
                local vs_toolset_ver = import("core.base.semver").new(vs_toolset)
                local minor = vs_toolset_ver:minor()
                assert(minor and minor >= 30, "package(bqlog) require vs_toolset >= 14.3")
            end
        end)
    end

    on_install("windows|x64", "linux", "macosx", "bsd", "android", "iphoneos", function (package)
        if package:config("shared") then
            package:add("defines", "BQ_DYNAMIC_LIB_IMPORT")
        end

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
            cmake_minimum_required(VERSION 3.22)
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
        io.replace("src/CMakeLists.txt", [[set_xcode_property(BqLog GCC_GENERATE_DEBUGGING_SYMBOLS NO "ALL")]],
        [[  macro (set_xcode_property TARGET XCODE_PROPERTY XCODE_VALUE)
            set_xcode_property(BqLog GCC_GENERATE_DEBUGGING_SYMBOLS NO "ALL")
            endmacro (set_xcode_property)
        ]], {plain = true})
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
