local build_defines

package("miniaudio")
    set_homepage("https://miniaud.io")
    set_description("Single file audio playback and capture library written in C.")

    set_urls("https://github.com/mackron/miniaudio/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mackron/miniaudio.git")
    add_versions("0.11.21", "6afb5c231613d2fab4f1c668b7243ff9a7d6d78a7f5a2692c133f026fe508506")
    add_versions("0.11.15", "24a6d38fe69cd42d91f6c1ad211bb559f6c89768c4671fa05b8027f5601d5457")
    add_versions("0.11.16", "13320464820491c61bd178b95818fecb7cd0e68f9677d61e1345df6be8d4d77e")
    add_versions("0.11.17", "4b139065f7068588b73d507d24e865060e942eb731f988ee5a8f1828155b9480")
    add_versions("0.11.18", "85ca916266d809b39902e180a6d16f82caea9c2ea1cea6d374413641b7ba48c3")

    local backends = {"aaudio", "audio4", "alsa", "coreaudio", "dsound", "jack", "null", "opensl", "oss", "pulseaudio", "wasapi", "webaudio", "winmm"}

    add_configs("headeronly", {description = "Install the headeronly version (or the split one if disabled).", default = true, type = "boolean"})

    add_configs("avx2", {description = "Enable AVX2 optimizations", default = true, type = "boolean"})
    add_configs("decoding", {description = "Enable decoding APIs", default = true, type = "boolean"})
    add_configs("device_io", {description = "Enable playback and recording", default = true, type = "boolean"})
    add_configs("disabled_backends", {description = "Disabled backends (none if empty)", default = {}, type = "table"})
    add_configs("encoding", {description = "Enable encoding APIs", default = true, type = "boolean"})
    add_configs("enabled_backends", {description = "Enabled backends (all if empty)", default = {}, type = "table"})
    add_configs("engine", {description = "Enable the engine API", default = true, type = "boolean"})
    add_configs("flac", {description = "Enable the builtin FLAC decoder", default = true, type = "boolean"})
    add_configs("generation", {description = "Enable the generation APIs", default = true, type = "boolean"})
    add_configs("mp3", {description = "Enable the builtin MP3 decoder", default = true, type = "boolean"})
    add_configs("neon", {description = "Enable Neon optimizations", default = true, type = "boolean"})
    add_configs("node_graph", {description = "Enable the node graph API (required for engine)", default = true, type = "boolean"})
    add_configs("resource_manager", {description = "Enable the resource manager", default = true, type = "boolean"})
    add_configs("sse2", {description = "Enable SSE2 optimizations", default = true, type = "boolean"})
    add_configs("threading", {description = "Enable the threading API", default = true, type = "boolean"})
    add_configs("wav", {description = "Enable the builtin WAV decoder and encoder", default = true, type = "boolean"})

    if is_plat("iphoneos") then
        add_frameworks("AudioToolbox", "AVFoundation", "CoreFoundation", "Foundation")
    elseif is_plat("macosx") then
        add_defines("MA_NO_RUNTIME_LINKING")
        add_frameworks("AudioToolbox", "CoreAudio", "AudioUnit", "AVFoundation", "CoreFoundation", "Foundation")
    end

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        if package:config("headeronly") then
            package:set("kind", "library", {headeronly = true})
        end
        local defines = build_defines(package)
        if #defines > 0 then
            package:add("defines", table.unwrap(defines))
        end
    end)

    on_install(function (package)
        if package:config("headeronly") then
            os.cp("miniaudio.h", package:installdir("include"))
        else
            local defines = build_defines(package)
            if is_plat("macosx", "iphoneos") then
                io.writefile("extras/miniaudio_split/miniaudio.m", "#include \"miniaudio.c\"")
            end
            local definelist = table.concat(table.imap(defines, function (_, d) return "    add_defines(\"" .. d .. "\")" end), "\n")
            io.writefile("xmake.lua", [[
add_rules("mode.debug", "mode.release")

target("miniaudio")
    set_kind("$(kind)")
    add_headerfiles("extras/miniaudio_split/(miniaudio.h)")
    if is_plat("macosx", "iphoneos") then
        add_files("extras/miniaudio_split/miniaudio.m")
    else
        add_files("extras/miniaudio_split/miniaudio.c")
    end

    add_defines("MINIAUDIO_IMPLEMENTATION")
            ]] .. definelist)
            import("package.tools.xmake").install(package)
        end
        os.cp("extras/nodes", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ma_version", {includes = "miniaudio.h", defines = package:config("headeronly") and "MINIAUDIO_IMPLEMENTATION" or nil}))
    end)

build_defines = function (package)
    local defines = {}
    if not package:config("headeronly") and package:config("shared") then
        table.insert(defines, "MA_DLL")
    end

    local available_backends = table.values(backends)
    local enabled_backends = package:config("enabled_backends")
    if #enabled_backends > 0 then
        table.insert(defines, "MA_ENABLE_ONLY_SPECIFIC_BACKENDS")
        for _, backend in ipairs(enabled_backends) do
            if not available_backends[backend] then
                os.raise("unknown backend " .. backend)
            end
            table.insert(defines, "MA_ENABLE_" .. backend:upper())
        end
    end
    local disabled_backends = package:config("disabled_backends")
    for _, backend in ipairs(disabled_backends) do
        for _, backend in ipairs(enabled_backends) do
            if not available_backends[backend] then
                os.raise("unknown backend " .. backend)
            end
            table.insert(defines, "MA_NO_" .. backend:upper())
        end
    end
    if not package:config("avx2") then
        table.insert(defines, "MA_NO_AVX2")
    end
    if not package:config("decoding") then
        table.insert(defines, "MA_NO_DECODING")
    end
    if not package:config("device_io") then
        table.insert(defines, "MA_NO_DEVICE_IO")
    end
    if not package:config("encoding") then
        table.insert(defines, "MA_NO_ENCODING")
    end
    if not package:config("engine") then
        table.insert(defines, "MA_NO_ENGINE")
    end
    if not package:config("flac") then
        table.insert(defines, "MA_NO_FLAC")
    end
    if not package:config("generation") then
        table.insert(defines, "MA_NO_GENERATION")
    end
    if not package:config("mp3") then
        table.insert(defines, "MA_NO_MP3")
    end
    if not package:config("neon") then
        table.insert(defines, "MA_NO_NEON")
    end
    if not package:config("node_graph") then
        table.insert(defines, "MA_NO_NODE_GRAPH")
    end
    if not package:config("resource_manager") then
        table.insert(defines, "MA_NO_RESOURCE_MANAGER")
    end
    if not package:config("sse2") then
        table.insert(defines, "MA_NO_SSE2")
    end
    if not package:config("threading") then
        table.insert(defines, "MA_NO_THREADING")
    end
    if not package:config("wav") then
        table.insert(defines, "MA_NO_WAV")
    end
    return table.unique(defines)
end
