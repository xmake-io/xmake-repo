package("juce")

    set_kind("library", {headeronly = true})
    set_homepage("https://juce.com/")
    set_description("JUCE is an open-source cross-platform C++ application framework for creating high quality desktop and mobile applications, including VST, VST3, AU, AUv3, AAX and LV2 audio plug-ins.")

    add_urls("https://github.com/juce-framework/JUCE/archive/refs/tags/$(version).tar.gz",
             "https://github.com/juce-framework/JUCE.git")
    add_versions("7.0.5", "a44a8545858e298c3e72094ea4219c05d5f29bd36473debc7d7a935b398dc57f")

    add_configs("extras", {description = "Build Projucer and other tools.", default = true, type = "boolean"})

    add_deps("cmake")
    on_load("windows", "macosx", "linux", function (package)
        package:add("includedirs", "include/JUCE-" .. package:version() .. "/modules")
        if package:is_plat("linux") and package:config("extras") then
            for _, pkg in ipairs({"freetype", "libxext","libxrandr", "libxinerama", "libxcursor"}) do
                package:add("deps", pkg, {private = true})
            end
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DJUCE_BUILD_EXTRAS=" .. (package:config("extras") and "ON" or "OFF")}
        if package:is_plat("linux") and package:config("extras") then
            import("package.tools.cmake").install(package, configs, {packagedeps = {"freetype", "libxext", "libxrender", "libxrandr", "libxinerama", "libxcursor"}})
        else
            import("package.tools.cmake").install(package, configs)
        end
        if package:config("extras") then
            package:addenv("PATH", "bin/JUCE-" .. package:version())
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #define JUCE_GLOBAL_MODULE_SETTINGS_INCLUDED
            #include <juce_core/juce_core.cpp>
            void test() {
                auto randomInt = juce::Random::getSystemRandom().nextInt();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
