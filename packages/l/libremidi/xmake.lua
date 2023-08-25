package("libremidi")
    set_homepage("https://github.com/jcelerier/libremidi")
    set_description("A modern C++ MIDI real-time & file I/O library. Supports Windows, macOS, Linux and WebMIDI.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/jcelerier/libremidi/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jcelerier/libremidi.git")

    add_versions("v3.0", "133b40396ca72e35d94cb0950199c9d123352951e4705971a9cd7606f905328a")

    add_configs("header_only", {description = "Use header only version.", default = false, type = "boolean"})
    add_configs("boost", {description = "Use boost::small_vector to pass midi bytes instead of std::vector to reduce allocations.", default = false, type = "boolean"})
    add_configs("jack", {description = "Enable JACK back-end", default = false, type = "boolean"})
    add_configs("slim_message", {description = "Use a fixed-size message format", default = "0", type = "string"})

    if is_plat("windows", "mingw") then
        add_syslinks("winmm")
    elseif is_plat("macosx") then
        add_frameworks("CoreFoundation", "CoreMIDI", "CoreAudio")
    elseif is_plat("iphoneos") then
        add_frameworks("CoreMIDI")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_load(function (package)
        if package:config("header_only") then
            package:set("library", {headeronly = true})
            package:add("defines", "LIBREMIDI_HEADER_ONLY=1")
            if package:config("jack") then
                package:add("defines", "LIBREMIDI_JACK=1")
            end

            if package:is_plat("windows") then
                package:add("defines", "LIBREMIDI_WINMM=1")
                -- TODO: support UWP
                -- package:add("defines", "LIBREMIDI_WINUWP=1")
            elseif package:is_plat("linux") then
                package:add("defines", "LIBREMIDI_ALSA=1")
            elseif package:is_plat("wasm") then
                package:add("defines", "LIBREMIDI_EMSCRIPTEN=1")
            end
        end
        if package:config("boost") then
            package:add("deps", "boost")
        end
    end)

    on_install(function (package)
        local configs = {"-DLIBREMIDI_EXAMPLES=OFF", "-DLIBREMIDI_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLIBREMIDI_HEADER_ONLY=" .. (package:config("header_only") and "ON" or "OFF"))
        table.insert(configs, "-DLIBREMIDI_NO_JACK=" .. (package:config("jack") and "OFF" or "ON"))
        table.insert(configs, "-DLIBREMIDI_SLIM_MESSAGE=" .. package:config("slim_message"))
        if package:config("boost") then
            table.insert(configs, "-DLIBREMIDI_NO_BOOST=OFF")
            table.insert(configs, "-DLIBREMIDI_FIND_BOOST=ON")
        else
            table.insert(configs, "-DLIBREMIDI_NO_BOOST=ON")
        end
        io.replace("CMakeLists.txt", "          ARCHIVE DESTINATION lib/static", "          ARCHIVE DESTINATION lib", {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        -- TODO: v4 version will break api
        assert(package:check_cxxsnippets({test = [[
            #include <libremidi/libremidi.hpp>
            void test() {
                libremidi::midi_in midi;
                for (int i = 0, N = midi.get_port_count(); i < N; i++) {
                    std::string name = midi.get_port_name(i);
                }
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
