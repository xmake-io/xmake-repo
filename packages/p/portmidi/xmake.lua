package("portmidi")
    set_homepage("https://github.com/PortMidi/portmidi")
    set_description("portmidi is a cross-platform MIDI input/output library")

    add_urls("https://github.com/PortMidi/portmidi/archive/refs/tags/$(version).tar.gz",
             "https://github.com/PortMidi/portmidi.git")

    add_versions("v2.0.4", "64893e823ae146cabd3ad7f9a9a9c5332746abe7847c557b99b2577afa8a607c")

    if is_plat("windows", "mingw") then
        add_syslinks("winmm")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    elseif is_plat("macosx") then
        add_frameworks("CoreAudio", "CoreFoundation", "CoreMIDI", "CoreServices")
    end

    add_deps("cmake")

    if is_plat("linux") then
        add_deps("alsa-lib")    
    end

    on_install(function (package)
        io.replace("pm_common/CMakeLists.txt", [[MSVC_RUNTIME_LIBRARY]], "", {plain = true})
        io.replace("pm_common/CMakeLists.txt", [["MultiThreaded$<$<CONFIG:Debug>:Debug>${MSVCRT_DLL}"]], "", {plain = true})
        io.replace("pm_win/pmwinmm.c", "midi->fill_offset_ptr = &(hdr->dwBytesRecorded);", "midi->fill_offset_ptr = (uint32_t *) &(hdr->dwBytesRecorded);", {plain = true})
        local configs = {"-DBUILD_PORTMIDI_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("Pm_Initialize", {includes = "portmidi.h"}))
    end)
