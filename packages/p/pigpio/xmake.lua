package("pigpio")
    set_homepage("https://github.com/joan2937/pigpio")
    set_description("pigpio is a C library for the Raspberry which allows control of the General Purpose Input Outputs (GPIO).")

    add_urls("https://github.com/joan2937/pigpio/archive/refs/tags/$(version).tar.gz",
             "https://github.com/joan2937/pigpio.git")

    add_versions("v79", "c5337c0b7ae888caf0262a6f476af0e2ab67065f7650148a0b21900b8d1eaed7")

    add_syslinks("pthread")

    add_deps("cmake")

    on_install("linux", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <pigpio.h>
            void test() {
                gpioSetMode(0, PI_INPUT);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
