package("cpu_features")
    set_homepage("https://github.com/google/cpu_features")
    set_description("A cross platform C99 library to get cpu features at runtime.")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/cpu_features/archive/refs/tags/$(version).tar.gz",
             "https://github.com/google/cpu_features.git")

    add_versions("v0.8.0", "7021729f2db97aa34f218d12727314f23e8b11eaa2d5a907e8426bcb41d7eaac")

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cpu_features/cpuinfo_x86.h>
            using namespace cpu_features;
            void test() {
                static const X86Features features = GetX86Info().features;
            }
        ]]}, {configs = {languages = "c++14"}}))
        assert(package:has_cfuncs("GetX86Info", {includes = "cpu_features/cpuinfo_x86.h"}))
    end)
