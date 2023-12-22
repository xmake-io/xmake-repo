package("cppgpio")
    set_homepage("https://github.com/JoachimSchurig/CppGPIO")
    set_description("C++14 GPIO library for embedded systems on Linux")

    add_urls("https://github.com/JoachimSchurig/CppGPIO/archive/refs/tags/$(version).tar.gz",
             "https://github.com/JoachimSchurig/CppGPIO.git")

    add_versions("v1.0.2", "53172c0f02516861bca1d1095d9275d569427ec99d63ca2b21ab8d42589c6bb1")

    on_install("linux", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("cppgpio")
                set_kind("$(kind)")
                set_languages("cxx14")
                add_files("src/*.cpp")
                add_headerfiles("include/(**.hpp)")
                add_headerfiles("src/tools.hpp")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cppgpio.hpp>
            using namespace GPIO;
            void test() {
                PWMOut pwm(23, 100, 0);
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
