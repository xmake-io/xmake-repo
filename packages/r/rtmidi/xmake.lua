package("rtmidi")
    set_homepage("https://github.com/thestk/rtmidi")
    set_description("A set of C++ classes that provide a common API for realtime MIDI input/output across Linux (ALSA & JACK), Macintosh OS X (CoreMIDI) and Windows (Multimedia)")

    add_urls("https://github.com/thestk/rtmidi/archive/refs/tags/$(version).tar.gz",
             "https://github.com/thestk/rtmidi.git")

    add_versions("6.0.0", "ef7bcda27fee6936b651c29ebe9544c74959d0b1583b716ce80a1c6fea7617f0")

    if is_plat("windows", "mingw") then
        add_syslinks("winmm")
    elseif is_plat("macosx") then
        add_frameworks("CoreFoundation", "CoreMIDI", "CoreAudio", "CoreServices")
    elseif is_plat("iphoneos") then
        add_frameworks("CoreMIDI")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    elseif is_plat("android") then
        add_syslinks("amidi")
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DRTMIDI_BUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <rtmidi/RtMidi.h>
            void test() {
                try {
                    RtMidiIn midiin;
                } catch (RtMidiError &error) {
                    error.printMessage();
                }
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
