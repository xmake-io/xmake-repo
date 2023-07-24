package("cpuinfo")
    set_homepage("https://github.com/pytorch/cpuinfo")
    set_description("CPU INFOrmation library (x86/x86-64/ARM/ARM64, Linux/Windows/Android/macOS/iOS)")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/pytorch/cpuinfo.git")
    add_versions("2022.09.15", "de2fa78ebb431db98489e78603e4f77c1f6c5c57")
    add_versions("2023.07.21", "60480b7098c8ddc73d611285fc478dec66e4edf9")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    if is_plat("linux", "macosx", "bsd") then
        add_syslinks("pthread")
    end

    on_install("windows", "linux", "macosx", "bsd", "android", function (package)
        local configs = {"-DCPUINFO_BUILD_TOOLS=OFF",
                         "-DCPUINFO_BUILD_UNIT_TESTS=OFF",
                         "-DCPUINFO_BUILD_MOCK_TESTS=OFF",
                         "-DCPUINFO_BUILD_BENCHMARKS=OFF",
                         "-DCPUINFO_BUILD_PKG_CONFIG=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DCPUINFO_LIBRARY_TYPE=" .. (package:config("shared") and "shared" or "static"))
        if package:is_plat("windows") then
            table.insert(configs, "-DCPUINFO_RUNTIME_TYPE=" .. (package:config("vs_runtime"):startswith("MT") and "static" or "shared"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
         assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            void test(int args, char** argv) {
                cpuinfo_initialize();
                std::cout << "Running on %s CPU " << cpuinfo_get_package(0)->name;
            }
        ]]}, {configs = {languages = "c++11"}, includes = "cpuinfo.h"}))
    end)
