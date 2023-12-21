package("pipca9685")
    set_homepage("https://github.com/barulicm/PiPCA9685")
    set_description("C++ and Python Library for PCA9685 chips and the Raspberry Pi")
    set_license("MIT")

    add_urls("https://github.com/barulicm/PiPCA9685.git")
    add_versions("2022.07.03", "a9edfc9df0ac00a616f0ef2801804b17e4742471")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("pipca9685")
                set_kind("$(kind)")
                set_languages("cxx14")

                add_includedirs("include")
                add_files("src/*.cpp")
                add_headerfiles("include/(PiPCA9685/PCA9685.h)")
                add_headerfiles("src/*.h")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <PiPCA9685/PCA9685.h>
            using namespace PiPCA9685;
            void test() {
                PCA9685 pca{};
                pca.set_pwm_freq(60.0);
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
