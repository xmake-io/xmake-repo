package("portaudio")
    set_homepage("http://www.portaudio.com")
    set_description("PortAudio is a cross-platform, open-source C language library for real-time audio input and output.")

    add_urls("https://github.com/PortAudio/portaudio.git")

    add_versions("2024.08.25", "3beece1baedab8acd7084d028df781efacaf31c4")
    add_versions("2023.08.05", "95a5c4ba645e01b32f70458f8ddcd92edd62f982")

    add_configs("skeleton", {description = "Use skeleton host API", default = false, type = "boolean"})
    add_configs("asio", {description = "Enable support for ASIO", default = false, type = "boolean"})
    if is_plat("windows") then
        add_configs("direct_sound", {description = "Enable support for DirectSound", default = true, type = "boolean"})
        add_configs("wmme", {description = "Enable support for WMME", default = true, type = "boolean"})
        add_configs("wasapi", {description = "Enable support for WASAPI", default = true, type = "boolean"})
        add_configs("wdmks", {description = "Enable support for WDMKS", default = true, type = "boolean"})
        add_configs("wdmks_devcie_info", {description = "Use WDM/KS API for device info", default = true, type = "boolean"})
    elseif is_plat("linux") then
        add_configs("alsa", {description = "Enable support for ALSA", default = true, type = "boolean"})
        add_configs("alsa_dynamic", {description = "Enable dynamically loading libasound with dlopen using PaAlsa_SetLibraryPathName", default = false, type = "boolean"})
    end

    if is_plat("windows", "mingw") then
        add_syslinks("user32", "winmm", "advapi32", "ole32", "setupapi")
    elseif is_plat("macosx") then
        add_frameworks("CoreFoundation", "CoreAudio", "AudioToolbox", "AudioUnit", "CoreServices")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_load(function (package)
        if package:config("alsa") then
            package:add("deps", "alsa-lib")
            package:add("defines", "PA_USE_ALSA=1")
        end
        if package:config("asio") then
            package:add("defines", "PA_USE_ASIO=1")
        end
        if package:config("direct_sound") then
            package:add("defines", "PA_USE_DS=1")
        end
        if package:config("wmme") then
            package:add("defines", "PA_USE_WMME=1")
        end
        if package:config("wasapi") then
            package:add("defines", "PA_USE_WASAPI=1")
        end
        if package:config("wdmks") then
            package:add("defines", "PA_USE_WDMKS=1")
        end
    end)

    on_install("!iphoneos", function (package)
        io.replace("CMakeLists.txt", [["${ALSA_LIBRARIES}"]], "ALSA::ALSA", {plain = true})

        local configs = {
            "-DPA_BUILD_TESTS=OFF",
            "-DPA_BUILD_EXAMPLES=OFF",
            "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW",
        }
        if package:is_debug() then
            table.insert(configs, "-DCMAKE_BUILD_TYPE=Debug")
            table.insert(configs, "-DPA_ENABLE_DEBUG_OUTPUT=ON")
        else
            table.insert(configs, "-DCMAKE_BUILD_TYPE=Release")
            table.insert(configs, "-DPA_ENABLE_DEBUG_OUTPUT=OFF")
        end
        table.insert(configs, "-DPA_BUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DPA_USE_SKELETON=" .. (package:config("skeleton") and "ON" or "OFF"))
        table.insert(configs, "-DPA_USE_ASIO=" .. (package:config("asio") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DPA_DLL_LINK_WITH_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
            table.insert(configs, "-DPA_USE_DS=" .. (package:config("direct_sound") and "ON" or "OFF"))
            table.insert(configs, "-DPA_USE_WMME=" .. (package:config("wmme") and "ON" or "OFF"))
            table.insert(configs, "-DPA_USE_WASAPI=" .. (package:config("wasapi") and "ON" or "OFF"))
            table.insert(configs, "-DPA_USE_WDMKS=" .. (package:config("wdmks") and "ON" or "OFF"))
            table.insert(configs, "-DPA_USE_WDMKS_DEVICE_INFO=" .. (package:config("wdmks_devcie_info") and "ON" or "OFF"))
        elseif package:is_plat("linux") then
            table.insert(configs, "-DPA_USE_ALSA=" .. (package:config("alsa") and "ON" or "OFF"))
            table.insert(configs, "-DPA_ALSA_DYNAMIC=" .. (package:config("alsa_dynamic") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("Pa_Initialize", {includes = "portaudio.h"}))
    end)
