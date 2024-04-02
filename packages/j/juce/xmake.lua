package("juce")
    set_homepage("https://juce.com/")
    set_description("JUCE is the most widely used framework for audio application and plug-in development. It is an open source C++ codebase that can be used to create standalone software on Windows, macOS, Linux, iOS and Android, as well as VST, VST3, AU, AUv3, AAX and LV2 plug-ins.")
    set_license("GPL")

    if is_plat("windows") then
        add_urls("https://github.com/juce-framework/JUCE/releases/download/7.0.11/juce-7.0.11-windows.zip")
        add_versions("7.0.11", "815e28abf18a217c6fe00da2af116c9243b97681ff99d579eef61c4e5668913e")
    elseif is_plat("linux") then
        add_urls("https://github.com/juce-framework/JUCE/releases/download/7.0.11/juce-7.0.11-linux.zip")
        add_versions("7.0.11", "f11dae4e9513d4e06e395e14939d8165424226ba47074390e7c15bc38e5bab11")
    elseif is_plat("macosx") then
        add_urls("https://github.com/juce-framework/JUCE/releases/download/7.0.11/juce-7.0.11-osx.zip")
        add_versions("7.0.11", "45c3bdd8d7f00d5d990cc1f85066d49629d40b411ae9624bda44524cc5a69058")
    end

    local modules = {
        "juce_analytics",
        "juce_audio_basics",
        "juce_audio_devices",
        "juce_audio_formats",
        "juce_audio_plugin_client",
        "juce_audio_processors",
        "juce_audio_utils",
        "juce_box2d",
        "juce_core",
        "juce_cryptography",
        "juce_data_structures",
        "juce_dsp",
        "juce_events",
        "juce_graphics",
        "juce_gui_basics",
        "juce_gui_extra",
        "juce_midi_ci",
        "juce_opengl",
        "juce_osc",
        "juce_product_unlocking",
        "juce_video"
    }

    for _, modulename in ipairs(modules) do
        add_configs(modulename, {description = format("Enable %s module", modulename:gsub("_", " ")), default = modulename == "juce_core" and true or false, type = "boolean", readonly = modulename == "juce_core" and true or false})
    end

    add_configs("utf", {description = "Set the character encoding type", default = "8", values = {"8", "16", "32"}})

    on_component("juce_analytics", function (package, component)
        component:add("deps", "juce_gui_basics")
    end)

    on_component("juce_audio_basics", function (package, component)
        component:add("deps", "juce_core")
        if package:is_plat("iphoneos") or package:is_plat("macosx") then
            component:add("frameworks", "Accelerate")
        end
    end)

    on_component("juce_audio_devices", function (package, component)
        component:add("deps", "juce_audio_basics", "juce_events")
        if package:is_plat("iphoneos") then
            component:add("frameworks", "CoreAudio", "CoreMIDI", "AudioToolbox", "AVFoundation")
        elseif package:is_plat("macosx") then
            component:add("frameworks", "CoreAudio", "CoreMIDI", "AudioToolbox")
        elseif package:is_plat("linux") then
            component:add("deps", "alsa-lib")
        elseif package:is_plat("mingw") then
            component:add("syslinks", "winmm")
        end
    end)

    on_component("juce_audio_formats", function (package, component)
        component:add("deps", "juce_audio_basics")
        if package:is_plat("iphoneos") then
            component:add("frameworks", "AudioToolbox", "QuartzCore")
        elseif package:is_plat("macosx") then
            component:add("frameworks", "CoreAudio", "CoreMIDI", "QuartzCore", "AudioToolbox")
        end
    end)

    on_component("juce_audio_plugin_client", function (package, component)
        component:add("deps", "juce_audio_processors")
    end)

    on_component("juce_audio_processors", function (package, component)
        component:add("deps", "juce_gui_extra", "juce_audio_basics")
        if package:is_plat("iphoneos") then
            component:add("frameworks", "AudioToolbox")
        elseif package:is_plat("macosx") then
            component:add("frameworks", "CoreAudio", "CoreMIDI", "AudioToolbox")
        end
    end)

    on_component("juce_audio_utils", function (package, component)
        component:add("deps", "juce_audio_processors", "juce_audio_formats", "juce_audio_devices")
        if package:is_plat("iphoneos") then
            component:add("frameworks", "CoreAudioKit")
        elseif package:is_plat("macosx") then
            component:add("frameworks", "CoreAudioKit", "DiscRecording")
        end
    end)

    on_component("juce_box2d", function (package, component)
        component:add("deps", "juce_graphics")
    end)

    on_component("juce_core", function (package, component)
        component:add("deps", "juce_audio_processors", "juce_audio_formats", "juce_audio_devices")
        if package:is_plat("iphoneos") then
            component:add("frameworks", "Foundation")
        elseif package:is_plat("macosx") then
            component:add("frameworks", "Cocoa", "Foundation", "IOKit", "Security")
        elseif package:is_plat("linux") then
            component:add("syslinks", "rt", "dl", "pthread")
        elseif package:is_plat("mingw") then
            component:add("syslinks", "uuid", "wsock32", "wininet", "version", "ole32", "ws2_32", "oleaut32", "imm32", "comdlg32", "shlwapi", "rpcrt4", "winmm")
        elseif package:is_plat("windows") then
            component:add("syslinks", "kernel32", "user32", "shell32", "gdi32", "vfw32", "comdlg32", "winmm", "wininet", "rpcrt4", "ole32", "advapi32", "ws2_32", "Version", "Imm32", "Shlwapi")
        end
    end)

    on_component("juce_cryptography", function (package, component)
        component:add("deps", "juce_core")
    end)

    on_component("juce_data_structures", function (package, component)
        component:add("deps", "juce_events")
    end)

    on_component("juce_dsp", function (package, component)
        component:add("deps", "juce_audio_formats")
        if package:is_plat("iphoneos") or package:is_plat("macosx") then
            component:add("frameworks", "Accelerate")
        end
    end)

    on_component("juce_events", function (package, component)
        component:add("deps", "juce_core")
    end)

    on_component("juce_graphics", function (package, component)
        component:add("deps", "juce_events")
        if package:is_plat("iphoneos") then
            component:add("frameworks", "CoreGraphics", "CoreImage", "CoreText", "QuartzCore")
        elseif package:is_plat("macosx") then
            component:add("frameworks", "Cocoa", "QuartzCore")
        elseif package:is_plat("linux") then
            component:add("deps", "freetype2")
        end
    end)

    on_component("juce_gui_basics", function (package, component)
        component:add("deps", "juce_graphics", "juce_data_structures")
        if package:is_plat("iphoneos") then
            component:add("frameworks", "CoreServices", "UIKit", "Metal", "MetalKit")
        elseif package:is_plat("macosx") then
            component:add("frameworks", "Cocoa", "QuartzCore", "Metal", "MetalKit")
        elseif package:is_plat("mingw") then
            component:add("syslinks", "dxgi")
        end
    end)

    on_component("juce_gui_basics", function (package, component)
        component:add("deps", "juce_gui_basics")
        if package:is_plat("iphoneos") then
            component:add("frameworks", "WebKit", "UserNotifications")
        elseif package:is_plat("macosx") then
            component:add("frameworks", "WebKit", "UserNotifications")
        end
    end)

    on_component("juce_midi_ci", function (package, component)
        component:add("deps", "juce_audio_basics")
    end)

    on_component("juce_opengl", function (package, component)
        component:add("deps", "juce_gui_extra", "opengl")
    end)

    on_component("juce_product_unlocking", function (package, component)
        component:add("deps", "juce_cryptography")
    end)

    on_component("juce_video", function (package, component)
        component:add("deps", "juce_gui_extra")
        if package:is_plat("iphoneos") or package:is_plat("macosx") then
            component:add("frameworks", "AVKit", "AVFoundation", "CoreMedia")
        end
    end)

    on_load(function (package)
        for _, modulename in ipairs(modules) do
            if package:config(modulename) then
                package:add("components", modulename)
            end
        end
        if package:is_plat("linux") then
            package:add("deps", "libcurl")
        end
    end)

    on_install(function (package)
        package:add("defines", "JUCE_GLOBAL_MODULE_SETTINGS_INCLUDED")
        local configs = {
            kind = package:config("shared") and "shared" or "static"
        }
        for _, modulename in ipairs(modules) do
            configs[modulename] = package:config(modulename)
        end
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <juce_core/juce_core.h>
            void test() {
                juce::String str("hello from juce");
                std::cout << str << std::endl;
            }
        ]]}, {configs = {languages = "c++17"}}))

        if package:config("juce_analytics") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_Analytics.h>
                void test() {
                    juce::Analytics::getInstance();
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("juce_audio_basics") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_AudioFormatReader.h>
                void test() {
                    juce::AudioFormatReader;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("juce_audio_devices") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_AudioIODeviceType.h>
                void test() {
                    juce::AudioIODeviceType;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("juce_audio_formats") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_AudioFormat.h>
                void test() {
                    juce::AudioFormat;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("juce_audio_plugin_client") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_AudioProcessor.h>
                void test() {
                    juce::AudioProcessor;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("juce_audio_processors") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_AudioProcessorGraph.h>
                void test() {
                    juce::AudioProcessorGraph;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("juce_audio_utils") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_AudioThumbnail.h>
                void test() {
                    juce::AudioThumbnail;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("juce_box2d") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_Box2D.h>
                void test() {
                    juce::Box2D;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("juce_cryptography") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_Cryptography.h>
                void test() {
                    juce::Cryptography;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("juce_data_structures") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_DataStructures.h>
                void test() {
                    juce::DataStructures;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("juce_dsp") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_DSP.h>
                void test() {
                    juce::dsp;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("juce_events") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_Events.h>
                void test() {
                    juce::Events;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("juce_graphics") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_Graphics.h>
                void test() {
                    juce::Graphics;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("juce_gui_basics") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_GUIBasics.h>
                void test() {
                    juce::GUIBasics;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("juce_gui_extra") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_GUIExtra.h>
                void test() {
                    juce::GUIExtra;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("juce_midi_ci") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_MidiCI.h>
                void test() {
                    juce::MidiCI;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("juce_opengl") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_OpenGL.h>
                void test() {
                    juce::OpenGL;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("juce_osc") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_OSC.h>
                void test() {
                    juce::OSC;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("juce_product_unlocking") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_ProductUnlocking.h>
                void test() {
                    juce::ProductUnlocking;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("juce_video") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_Video.h>
                void test() {
                    juce::Video;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end
    end)