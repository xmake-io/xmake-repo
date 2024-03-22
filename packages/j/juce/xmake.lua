package("juce")
    set_homepage("https://juce.com")
    set_description("JUCE is an open-source cross-platform C++ application framework for desktop and mobile applications, including VST, VST3, AU, AUv3, LV2 and AAX audio plug-ins.")

    add_urls("https://github.com/juce-framework/JUCE/archive/refs/tags/$(version).tar.gz",
             "https://github.com/juce-framework/JUCE.git")

    add_versions("7.0.9", "7a1beca23a41c1d9c3804c987d36edbe66fb3cf0169cef3348eab1b596130329")
    
    add_configs("modules_only", {description = "Only configure the JUCE modules", default = true, type = "boolean"})

    add_defines("JUCE_GLOBAL_MODULE_SETTINGS_INCLUDED")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DJUCE_MODULES_ONLY=" .. (package:config("modules_only") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)

        os.mv(package:installdir("include", "JUCE-" .. package:version(), "modules/*"), package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <juce_core/juce_core.h>
            void test() {
                const juce::String s = "hello";
                const auto x = s.toStdString();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
