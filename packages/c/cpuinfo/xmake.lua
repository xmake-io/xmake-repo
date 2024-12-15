package("cpuinfo")
    set_homepage("https://github.com/pytorch/cpuinfo")
    set_description("CPU INFOrmation library (x86/x86-64/ARM/ARM64, Linux/Windows/Android/macOS/iOS)")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/pytorch/cpuinfo.git")

    add_versions("2024.09.26", "1e83a2fdd3102f65c6f1fb602c1b320486218a99")
    add_versions("2023.07.21", "60480b7098c8ddc73d611285fc478dec66e4edf9")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end
    add_configs("clog", {description = "Build clog library.", default = false, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    add_deps("cmake")
    if is_plat("windows") then
        add_syslinks("advapi32")
    elseif is_plat("linux", "macosx", "bsd") then
        add_syslinks("pthread")
    end

    on_check("windows", function (package)
        import("core.tool.toolchain")
        import("core.base.semver")

        local msvc = toolchain.load("msvc", {plat = package:plat(), arch = package:arch()})
        if msvc and package:is_arch("arm.*") then
            local vs_sdkver = msvc:config("vs_sdkver")
            assert(vs_sdkver and semver.match(vs_sdkver):gt("10.0.19041"), "package(cpuinfo): need vs_sdkver > 10.0.19041.0")
        end
    end)

    on_load(function (package)
        if package:config("clog") then
            package:add("links", "cpuinfo", "clog")
        end
    end)

    on_install("!cross", function (package)
        local configs = {"-DCPUINFO_BUILD_TOOLS=OFF",
                         "-DCPUINFO_BUILD_UNIT_TESTS=OFF",
                         "-DCPUINFO_BUILD_MOCK_TESTS=OFF",
                         "-DCPUINFO_BUILD_BENCHMARKS=OFF",
                         "-DCPUINFO_BUILD_PKG_CONFIG=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DCPUINFO_LIBRARY_TYPE=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-DCPUINFO_BUILD_TOOLS=" .. (package:config("tools") and "ON" or "OFF"))

        if package:is_plat("mingw") then
            table.insert(configs, "-DCMAKE_SYSTEM_PROCESSOR=Windows")
        end
        if (package:is_cross() or package:is_plat("mingw")) and (not package:is_plat("android")) then
            io.replace("CMakeLists.txt", [[SET(CPUINFO_TARGET_PROCESSOR "${CMAKE_SYSTEM_PROCESSOR}")]], "", {plain = true})
            table.insert(configs, "-DCPUINFO_TARGET_PROCESSOR=" .. package:arch())
        end

        if package:is_plat("windows") then
            table.insert(configs, "-DCPUINFO_RUNTIME_TYPE=" .. (package:config("vs_runtime"):startswith("MT") and "static" or "shared"))
            local vs_sdkver = import("core.tool.toolchain").load("msvc"):config("vs_sdkver")
            if vs_sdkver then
                local build_ver = string.match(vs_sdkver, "%d+%.%d+%.(%d+)%.?%d*")
                assert(tonumber(build_ver) >= 18362, "cpuinfo requires Windows SDK to be at least 10.0.18362.0")
                table.insert(configs, "-DCMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION=" .. vs_sdkver)
                table.insert(configs, "-DCMAKE_SYSTEM_VERSION=" .. vs_sdkver)
            end
        end
        import("package.tools.cmake").install(package, configs)

        if package:config("clog") then
            import("clog")(package)
        end
    end)

    on_test(function (package)
         assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            void test(int args, char** argv) {
                cpuinfo_initialize();
                std::cout << "Running on CPU " << cpuinfo_get_package(0)->name;
            }
        ]]}, {configs = {languages = "c++11"}, includes = "cpuinfo.h"}))

        if package:config("clog") then
            assert(package:has_cfuncs("clog_vlog_info", {includes = "clog.h"}))
        end
    end)
