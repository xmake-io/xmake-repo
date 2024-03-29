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
        juce_analytics = {
            default = false,
            readonly = false,
            deps = {"juce_gui_basics"}
        },
        juce_audio_basics = {
            default = false,
            readonly = false,
            links = {
                iphoneos = {"Accelerate"},
                macosx = {"Accelerate"},
            },
            deps = {"juce_core"}
        },
        juce_audio_devices = {
            default = false,
            readonly = false,
            links = {
                iphoneos = {"CoreAudio", "CoreMIDI", "AudioToolbox"},
                macosx = {"CoreAudio", "CoreMIDI", "AudioToolbox", "AVFoundation"},
                linux = {"alsa"},
                mingw = {"winmm"}
            },
            deps = {"juce_audio_basics", "juce_events"}
        },
        juce_audio_formats = {
            default = false,
            readonly = false,
            links = {
                iphoneos = {"AudioToolbox", "QuartzCore"},
                macosx = {"CoreAudio", "CoreMIDI", "QuartzCore", "AudioToolbox"},
            },
            deps = {"juce_audio_basics", "juce_events"}
        },
        juce_audio_plugin_client = {
            default = false,
            readonly = false,
            deps = {"juce_audio_processors"}
        },
        juce_audio_processors = {
            default = false,
            readonly = false,
            links = {
                iphoneos = {"AudioToolbox"},
                macosx = {"CoreAudio", "CoreMIDI", "AudioToolbox"},
            },
            deps = {"juce_gui_extra", "juce_audio_basics"}
        },
        juce_audio_utils = {
            default = false,
            readonly = false,
            links = {
                iphoneos = {"CoreAudioKit"},
                macosx = {"CoreAudioKit", "DiscRecording"},
            },
            deps = {"juce_audio_processors", "juce_audio_formats", "juce_audio_devices"}
        },
        juce_box2d = {
            default = false,
            readonly = false,
            deps = {"juce_graphics"}
        },
        juce_core = {
            default = true,
            readonly = true,
            links = {
                windows = {"kernel32", "user32", "shell32", "gdi32", "vfw32", "comdlg32", "winmm", "wininet", "rpcrt4", "ole32", "advapi32", "ws2_32", "Version", "Imm32", "Shlwapi"},
                linux = {"rt", "dl", "pthread"},
                macosx = {"Cocoa", "Foundation", "IOKit", "Security"},
                iphoneos = {"Foundation"},
                mingw = {"uuid", "wsock32", "wininet", "version", "ole32", "ws2_32", "oleaut32", "imm32", "comdlg32", "shlwapi", "rpcrt4", "winmm"}
            }
        },
        juce_cryptography = {
            default = true,
            readonly = true,
            deps = {"juce_core"}
        },
        juce_data_structures = {
            default = true,
            readonly = true,
            deps = {"juce_events"}
        },
        juce_dsp = {
            default = false,
            readonly = false,
            links = {
                iphoneos = {"Accelerate"},
                macosx = {"Accelerate"},
            },
            deps = {"juce_audio_formats"}
        },
        juce_events = {
            default = false,
            readonly = false,
            deps = {"juce_core"}
        },
        juce_graphics = {
            default = false,
            readonly = false,
            links = {
                iphoneos = {"CoreGraphics", "CoreImage", "CoreText", "QuartzCore"},
                macosx = {"Cocoa", "QuartzCore"},
                linux = {"freetype2"}
            },
            deps = {"juce_events"}
        },
        juce_gui_basics = {
            default = false,
            readonly = false,
            links = {
                iphoneos = {"CoreServices", "UIKit", "Metal", "MetalKit"},
                macosx = {"Cocoa", "QuartzCore", "Metal", "MetalKit"},
                linux = {"freetype2"},
                mingw = {"dxgi"}
            },
            deps = {"juce_graphics", "juce_data_structures"}
        },
        juce_gui_extra = {
            default = false,
            readonly = false,
            links = {
                iphoneos = {"WebKit", "UserNotifications"},
                macosx = {"WebKit", "UserNotifications"},
            },
            deps = {"juce_gui_basics"}
        },
        juce_midi_ci = {
            default = false,
            readonly = false,
            deps = {"juce_audio_basics"}
        },
        juce_opengl = {
            default = false,
            readonly = false,
            links = {
                iphoneos = {"OpenGLES"},
                macosx = {"OpenGL"},
                linux = {"hl"},
                mingw = {"opengl32"}
            },
            deps = {"juce_gui_extra"}
        },
        juce_osc = {
            default = false,
            readonly = false,
            deps = {"juce_events"}
        },
        juce_product_unlocking = {
            default = false,
            readonly = false,
            deps = {"juce_cryptography"}
        },
        juce_video = {
            default = false,
            readonly = false,
            links = {
                iphoneos = {"AVKit", "AVFoundation", "CoreMedia"},
                macosx = {"AVKit", "AVFoundation", "CoreMedia"},
            },
            deps = {"juce_cryptography"}
        }
    }

    for modulename, options in table.orderpairs(modules) do
        add_configs(modulename, {description = format("Enable %s module", modulename:gsub("_", " ")), default = options.default, type = "boolean", readonly = options.readonly})
    end

    add_configs("utf", {description = "Set the character encoding type", default = "8", values = {"8", "16", "32"}})

    on_install(function (package)
        package:add("defines", "JUCE_GLOBAL_MODULE_SETTINGS_INCLUDED")
        local file = format([[
            add_rules("mode.debug", "mode.release")
            target("juce")
                set_kind("$(kind)")
                set_languages("cxx17")
                add_defines("JUCE_GLOBAL_MODULE_SETTINGS_INCLUDED", {public = true})
                add_defines("JUCE_STRING_UTF_TYPE=8", {public = true})
                if is_kind("shared") then
                    add_defines("JUCE_DLL_BUILD")
                end
        ]], package:config("utf"))
        for modulename, options in pairs(modules) do
            local links = options.links or {}
            local sysLinks = '"' .. table.concat(links[os.host()] or {}, '", "') .. '"'
            for _, link in ipairs(links[os.host()] or {}) do
                package:add("links", link)
            end
            if package:config(modulename) then
                file = file .. format([[
                    do
                        local module = "%s"
                        add_files("modules/" .. module .. "/" .. module .. ".cpp")
                        add_includedirs("modules/", { public = true })
                        add_headerfiles("modules/(" .. module .. "/" .. module .. ".h)")
                        for _, dir in ipairs(os.dirs("modules/" .. module .. "/**")) do
                            add_includedirs(dir, { public = true })
                            add_headerfiles("modules/(" .. dir:gsub("modules\\", "") .. "/*.h)")
                        end
                        add_syslinks(%s)
                    end
                ]], modulename, sysLinks)
            end
        end

        io.writefile("xmake.lua", file)
        local configs = {kind = package:config("shared") and "shared" or "static"}
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
    end)