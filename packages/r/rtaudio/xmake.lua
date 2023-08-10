package("rtaudio")
    set_homepage("https://github.com/thestk/rtaudio")
    set_description("A set of C++ classes that provide a common API for realtime audio input/output across Linux (native ALSA, JACK, PulseAudio and OSS), Macintosh OS X (CoreAudio and JACK), and Windows (DirectSound, ASIO, and WASAPI) operating systems.")

    add_urls("https://github.com/thestk/rtaudio/archive/refs/tags/$(version).tar.gz",
             "https://github.com/thestk/rtaudio.git")

    add_versions("6.0.0", "bbd637a45ab54ba999883410b9bdd84529c3ac894aee9a68fc3b9a6f0686b9fb")

    add_configs("asio", {description = "Build ASIO API", default = false, type = "boolean"})
    add_configs("jack", {description = "Build JACK audio server API ", default = false, type = "boolean"})
    if is_plat("windows") then
        add_configs("direct_sound", {description = "Build DirectSound API", default = false, type = "boolean"})
        add_configs("wasapi", {description = "Build WASAPI API", default = true, type = "boolean"})
    elseif is_plat("linux") then
        add_configs("alsa", {description = "Build ALSA API", default = true, type = "boolean"})
        add_configs("pulseaudio", {description = "Build PulseAudio API", default = false, type = "boolean"})
    elseif is_plat("macosx") then
        add_configs("coreaudio", {description = "Build CoreAudio API", default = true, type = "boolean"})
    elseif is_plat("bsd") then
        add_configs("oss", {description = "Build OSS4 API", default = true, type = "boolean"})
    end

    if is_plat("windows", "mingw") then
        add_syslinks("winmm", "ole32", "mfplat", "mfuuid", "ksuser", "wmcodecdspuuid")
    elseif is_plat("macosx") then
        add_frameworks("CoreFoundation", "CoreAudio")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DRTAUDIO_BUILD_PYTHON=OFF"}
        if package:is_debug() then
            table.insert(configs, "-DCMAKE_BUILD_TYPE=ON")
            package:add("defines", "__RTAUDIO_DEBUG__")
        else
            table.insert(configs, "-DCMAKE_BUILD_TYPE=OFF")
        end
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DRTAUDIO_API_ASIO=" .. (package:config("asio") and "ON" or "OFF"))
        table.insert(configs, "-DRTAUDIO_API_JACK=" .. (package:config("jack") and "ON" or "OFF"))
        if is_plat("windows") then
            table.insert(configs, "-DRTAUDIO_API_DS=" .. (package:config("direct_sound") and "ON" or "OFF"))
            table.insert(configs, "-DRTAUDIO_API_WASAPI=" .. (package:config("wasapi") and "ON" or "OFF"))
        elseif is_plat("linux") then
            table.insert(configs, "-DRTAUDIO_API_ALSA=" .. (package:config("alsa") and "ON" or "OFF"))
            table.insert(configs, "-DRTAUDIO_API_PULSE=" .. (package:config("pulseaudio") and "ON" or "OFF"))
        elseif is_plat("macosx") then
            table.insert(configs, "-DRTAUDIO_API_CORE=" .. (package:config("coreaudio") and "ON" or "OFF"))
        elseif is_plat("bsd") then
            table.insert(configs, "-DRTAUDIO_API_OSS=" .. (package:config("oss") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("rtaudio_version", {includes = "rtaudio_c.h"}))
        assert(package:check_cxxsnippets({test = [[
            #include <RtAudio.h>
            void test() {
                RtAudio::DeviceInfo info;
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
