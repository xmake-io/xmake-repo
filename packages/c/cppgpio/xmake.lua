package("cppgpio")
    set_homepage("https://github.com/JoachimSchurig/CppGPIO")
    set_description("C++14 GPIO library for embedded systems on Linux")

    set_urls("https://github.com/JoachimSchurig/CppGPIO.git")

    add_versions("2022.02.20", "f76e8fc8f8fa8d8b5643ba9dfac44de7664c9c23")
    add_versions("2016.04.04", "2653a5876df8d23041eddc56e57ebd5e3ac167d1")
    add_versions("2016.03.11", "ba6fc634ebe2b519dba98dd11dc36dbda331ecc0")

    on_install("linux", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("cppgpio")
                set_kind("$(kind)")
                set_languages("cxx14")
                add_files("src/*.cpp")
                add_includedirs("include")
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
