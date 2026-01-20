package("libremidi")
    set_homepage("https://github.com/jcelerier/libremidi")
    set_description("A modern C++ MIDI real-time & file I/O library. Supports Windows, macOS, Linux and WebMIDI.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/jcelerier/libremidi/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jcelerier/libremidi.git")

    add_versions("v5.4.2", "ae1176e4729bc98c8d0d48b436efa62bbca1c3a113eb544117d3e5a27475e60f")
    add_versions("v5.3.1", "b68cdb81feb168bfafa44a139c76b459ff622e75c36fda76b39baf2f3efabdd6")
    add_versions("v5.3.0", "56d23d13c8d3fc40f0b46442af320865d485da908ad52d8950a87e05f9073c87")
    add_versions("v5.2.0", "d34a2e8aaede56f234f0f1b653fef0d84aeae1084e66d71c7237c85280d4be1a")
    add_versions("v5.1.0", "bd5f2f81fbed58c9d926741f5df5ec5b714854004492d1cf30609f650e199338")
    add_versions("v4.5.0", "2e884a4c826dd87157ee4fab8cd8c7b9dbbc1ddb804cb10ef0852094200724db")
    add_versions("v3.0", "133b40396ca72e35d94cb0950199c9d123352951e4705971a9cd7606f905328a")

    add_configs("header_only", {description = "Use header only version.", default = false, type = "boolean"})
    add_configs("boost", {description = "Use boost::small_vector to pass midi bytes instead of std::vector to reduce allocations.", default = false, type = "boolean"})
    add_configs("slim_message", {description = "Use a fixed-size message format", default = "0", type = "string"})

    add_configs("win_mm", {description = "Enable WinMM back-end", default = is_plat("windows", "mingw"), type = "boolean"})
    add_configs("win_uwp", {description = "Enable UWP back-end", default = false, type = "boolean"})
    add_configs("win_midi", {description = "Enable WinMIDI back-end", default = false, type = "boolean"})
    add_configs("jack", {description = "Enable JACK back-end", default = false, type = "boolean"})

    if is_plat("macosx") then
        add_frameworks("CoreFoundation", "CoreMIDI", "CoreAudio")
    elseif is_plat("iphoneos") then
        add_frameworks("CoreMIDI")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk")
            local ndk_sdkver = ndk:config("ndk_sdkver")
            if package:version() and package:version():ge("5.4.0") then
                assert(ndk_sdkver and tonumber(ndk_sdkver) >= 31, "package(libremidi): need ndk api level >= 31 for android")
            end
        end)
    end

    on_load(function (package)
        if package:config("header_only") then
            package:set("kind", "library", {headeronly = true})
            package:add("defines", "LIBREMIDI_HEADER_ONLY")
        end
        if package:config("shared") then
            package:add("defines", "LIBREMIDI_EXPORTS")
        end

        if package:config("jack") then
            package:add("defines", "LIBREMIDI_JACK")
        end

        if package:config("win_mm") then
            package:add("defines", "LIBREMIDI_WINMM")
            package:add("syslinks", "winmm")
        end
        if package:config("win_uwp") then
            package:add("defines", "LIBREMIDI_WINUWP")
            package:add("syslinks", "RuntimeObject")
        end
        if package:config("win_midi") then
            -- TODO: libremidi.winmidi.cmake will donwload winmidi-headers, package it or add_resources?
            package:add("defines", "LIBREMIDI_WINMIDI")
            package:add("syslinks", "RuntimeObject")
        end

        if package:is_plat("linux") then
            package:add("defines", "LIBREMIDI_ALSA")
        elseif package:is_plat("wasm") then
            package:add("defines", "LIBREMIDI_EMSCRIPTEN")
        end

        if package:config("boost") then
            package:add("deps", "boost")
        end
    end)

    on_install(function (package)
        io.replace("CMakeLists.txt", "          ARCHIVE DESTINATION lib/static", "          ARCHIVE DESTINATION lib", {plain = true})

        local configs = {"-DLIBREMIDI_EXAMPLES=OFF", "-DLIBREMIDI_TESTS=OFF", "-DLIBREMIDI_NO_WARNINGS=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLIBREMIDI_NO_EXPORTS=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DLIBREMIDI_HEADER_ONLY=" .. (package:config("header_only") and "ON" or "OFF"))
        table.insert(configs, "-DLIBREMIDI_SLIM_MESSAGE=" .. package:config("slim_message"))
        if package:config("boost") then
            table.insert(configs, "-DLIBREMIDI_NO_BOOST=OFF")
            table.insert(configs, "-DLIBREMIDI_FIND_BOOST=ON")
        else
            table.insert(configs, "-DLIBREMIDI_NO_BOOST=ON")
        end

        table.insert(configs, "-DLIBREMIDI_NO_JACK=" .. (package:config("jack") and "OFF" or "ON"))
        table.insert(configs, "-DLIBREMIDI_NO_WINMM=" .. (package:config("win_mm") and "OFF" or "ON"))
        table.insert(configs, "-DLIBREMIDI_NO_WINUWP=" .. (package:config("win_uwp") and "OFF" or "ON"))
        table.insert(configs, "-DLIBREMIDI_NO_WINMIDI=" .. (package:config("win_midi") and "OFF" or "ON"))

        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") and package:config("shared") then
            local src = "#define LIBREMIDI_EXPORT __declspec(dllexport)"
            local dst = "#define LIBREMIDI_EXPORT __declspec(dllimport)"
            local include = package:installdir("include/libremidi")
            io.replace(path.join(include, "config.hpp"), src, dst, {plain = true})
            io.replace(path.join(include, "libremidi-c.h"), src, dst, {plain = true})
        end
    end)

    on_test(function (package)
        local code
        if package:version() and package:version():lt("4.0.0") then
            code = [[
                void test() {
                    libremidi::midi_in midi;
                    for (int i = 0, N = midi.get_port_count(); i < N; i++) {
                        std::string name = midi.get_port_name(i);
                    }
                }
            ]]
        else
            code = [[
                void test() {
                    libremidi::observer obs;
                    for(const libremidi::input_port& port : obs.get_input_ports()) {}
                }
            ]]
        end

        assert(package:check_cxxsnippets({test = code}, {configs = {languages = "c++20"}, includes = {"libremidi/libremidi.hpp"}}))
    end)
