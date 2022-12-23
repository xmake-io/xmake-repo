package("cpuinfo")
    set_homepage("https://github.com/pytorch/cpuinfo")
    set_description("CPU INFOrmation library (x86/x86-64/ARM/ARM64, Linux/Windows/Android/macOS/iOS)")
    set_license("BSD 2-Clause")

    add_urls("https://github.com/pytorch/cpuinfo.git")
    add_versions("2022.09.15", "de2fa78ebb431db98489e78603e4f77c1f6c5c57")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
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
