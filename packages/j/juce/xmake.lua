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

    add_patches("7.0.11", path.join(os.scriptdir(), "patches", "7.0.11", "juce-build.patch"), "af5625959393e2c801e66056fb542914214c73ed47ac32413367e6b5e6e40ef3")

    local modules = {
        "analytics",
        "audio_basics",
        "audio_devices",
        "audio_formats",
        "audio_plugin_client",
        "audio_processors",
        "audio_utils",
        "box2d",
        "cryptography",
        "data_structures",
        "dsp",
        "events",
        "graphics",
        "gui_basics",
        "gui_extra",
        "midi_ci",
        "opengl",
        "osc",
        "product_unlocking",
        "video"
    }

    for _, modulename in ipairs(modules) do
        add_configs(modulename, {description = "Enable " .. modulename .. " module", default = false, type = "boolean"})
    end

    add_configs("utf", {description = "Set the character encoding type", default = "8", values = {"8", "16", "32"}})

    on_component("analytics", function (package, component)
        component:add("deps", "gui_basics")
    end)

    on_component("audio_basics", function (package, component)
        component:add("deps", "core")
        if package:is_plat("iphoneos") or package:is_plat("macosx") then
            component:add("frameworks", "Accelerate")
        end
    end)

    on_component("audio_devices", function (package, component)
        component:add("deps", "audio_basics", "juce_events")
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

    on_component("audio_formats", function (package, component)
        component:add("deps", "audio_basics")
        if package:is_plat("iphoneos") then
            component:add("frameworks", "AudioToolbox", "QuartzCore")
        elseif package:is_plat("macosx") then
            component:add("frameworks", "CoreAudio", "CoreMIDI", "QuartzCore", "AudioToolbox")
        end
    end)

    on_component("audio_plugin_client", function (package, component)
        component:add("deps", "audio_processors")
    end)

    on_component("audio_processors", function (package, component)
        component:add("deps", "gui_extra", "juce_audio_basics")
        if package:is_plat("iphoneos") then
            component:add("frameworks", "AudioToolbox")
        elseif package:is_plat("macosx") then
            component:add("frameworks", "CoreAudio", "CoreMIDI", "AudioToolbox")
        end
    end)

    on_component("audio_utils", function (package, component)
        component:add("deps", "audio_processors", "juce_audio_formats", "juce_audio_devices")
        if package:is_plat("iphoneos") then
            component:add("frameworks", "CoreAudioKit")
        elseif package:is_plat("macosx") then
            component:add("frameworks", "CoreAudioKit", "DiscRecording")
        end
    end)

    on_component("box2d", function (package, component)
        component:add("deps", "graphics")
    end)

    on_component("core", function (package, component)
        if package:is_plat("iphoneos") then
            component:add("frameworks", "Foundation")
        elseif package:is_plat("macosx") then
            component:add("frameworks", "Cocoa", "Foundation", "IOKit", "Security")
        elseif package:is_plat("linux") then
            component:add("syslinks", "rt", "dl", "pthread")
        elseif package:is_plat("mingw") then
            component:add("syslinks", "uuid", "wsock32", "wininet", "version", "ole32", "ws2_32", "oleaut32", "imm32", "comdlg32", "shlwapi", "rpcrt4", "winmm")
        elseif package:is_plat("windows") then
            component:add("syslinks", "kernel32", "user32", "shell32", "gdi32", "vfw32", "comdlg32", "winmm", "wininet", "rpcrt4", "ole32", "advapi32", "ws2_32", "Version", "Imm32", "Shlwapi", "OleAut32")
        elseif package:is_plat("android") then
            component:add("links", "libffi")
        end
        component:add("deps", "openssl")
    end)

    on_component("cryptography", function (package, component)
        component:add("deps", "core")
    end)

    on_component("data_structures", function (package, component)
        component:add("deps", "events")
    end)

    on_component("dsp", function (package, component)
        component:add("deps", "audio_formats")
        if package:is_plat("iphoneos") or package:is_plat("macosx") then
            component:add("frameworks", "Accelerate")
        end
    end)

    on_component("events", function (package, component)
        component:add("deps", "core")
    end)

    on_component("graphics", function (package, component)
        component:add("deps", "events")
        if package:is_plat("iphoneos") then
            component:add("frameworks", "CoreGraphics", "CoreImage", "CoreText", "QuartzCore")
        elseif package:is_plat("macosx") then
            component:add("frameworks", "Cocoa", "QuartzCore")
        elseif package:is_plat("linux") then
            component:add("deps", "freetype")
        end
    end)

    on_component("gui_basics", function (package, component)
        component:add("deps", "graphics", "juce_data_structures")
        if package:is_plat("iphoneos") then
            component:add("frameworks", "CoreServices", "UIKit", "Metal", "MetalKit")
        elseif package:is_plat("macosx") then
            component:add("frameworks", "Cocoa", "QuartzCore", "Metal", "MetalKit")
        elseif package:is_plat("mingw") then
            component:add("syslinks", "dxgi")
        elseif package:is_plat("linux") then
            component:add("deps", "xorgproto", "libxrandr", "libxrender", "libx11", "libxi", "libxcursor", "libxext", "libxdamage", "libxfixes", "libxinerama", "libxcomposite")
        end
    end)

    on_component("gui_extra", function (package, component)
        component:add("deps", "gui_basics")
        if package:is_plat("iphoneos") then
            component:add("frameworks", "WebKit", "UserNotifications")
        elseif package:is_plat("macosx") then
            component:add("frameworks", "WebKit", "UserNotifications")
        end
    end)

    on_component("midi_ci", function (package, component)
        component:add("deps", "audio_basics")
    end)

    on_component("opengl", function (package, component)
        component:add("deps", "gui_extra", "opengl")
        if package:is_plat("linux") then
            component:add("deps", "glu")
        end
    end)

    on_component("product_unlocking", function (package, component)
        component:add("deps", "cryptography")
    end)

    on_component("video", function (package, component)
        component:add("deps", "gui_extra")
        if package:is_plat("iphoneos") or package:is_plat("macosx") then
            component:add("frameworks", "AVKit", "AVFoundation", "CoreMedia")
        end
    end)

    on_load(function (package)
        package:add("components", "core")
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
            utf = package:config("utf")
        }
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

        if package:config("analytics") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_analytics/juce_Analytics.h>
                void test() {
                    juce::Analytics::getInstance();
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("audio_basics") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_audio_basics/juce_AudioFormatReader.h>
                void test() {
                    juce::AudioFormatReader;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("audio_devices") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_audio_devices/juce_AudioIODeviceType.h>
                void test() {
                    juce::AudioIODeviceType;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("audio_formats") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_audio_formats/juce_AudioFormat.h>
                void test() {
                    juce::AudioFormat;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("audio_plugin_client") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_audio_plugin_client/juce_AudioProcessor.h>
                void test() {
                    juce::AudioProcessor;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("audio_processors") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_audio_processors/juce_AudioProcessorGraph.h>
                void test() {
                    juce::AudioProcessorGraph;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("audio_utils") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_audio_utils/juce_AudioThumbnail.h>
                void test() {
                    juce::AudioThumbnail;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("box2d") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_box2d/juce_Box2D.h>
                void test() {
                    juce::Box2D;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("cryptography") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_cryptography/juce_Cryptography.h>
                void test() {
                    juce::Cryptography;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("data_structures") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_data_structures/juce_DataStructures.h>
                void test() {
                    juce::DataStructures;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("dsp") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_dsp/juce_DSP.h>
                void test() {
                    juce::dsp;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("events") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_events/juce_Events.h>
                void test() {
                    juce::Events;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("graphics") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_graphics/juce_Graphics.h>
                void test() {
                    juce::Graphics;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("gui_basics") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_gui_basics/juce_gui_basics.h>
                void test() {
                    juce::AccessibilityActions accessibilityActions;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("gui_extra") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_gui_extra/juce_gui_extra.h>
                void test() {
                    juce::CPlusPlusCodeTokeniser tokeniser;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("midi_ci") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_midi_ci/juce_MidiCI.h>
                void test() {
                    juce::MidiCI;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("opengl") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_opengl/juce_OpenGL.h>
                void test() {
                    juce::OpenGL;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("osc") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_osc/juce_OSC.h>
                void test() {
                    juce::OSC;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("product_unlocking") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_product_unlocking/juce_ProductUnlocking.h>
                void test() {
                    juce::ProductUnlocking;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("video") then
            assert(package:check_cxxsnippets({test = [[
                #include <juce_video/juce_Video.h>
                void test() {
                    juce::Video;
                }
            ]]}, {configs = {languages = "c++17"}}))
        end
    end)