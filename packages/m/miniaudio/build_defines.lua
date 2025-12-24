import("core.base.hashset")

local available_backends = hashset.from{"aaudio", "audio4", "alsa", "coreaudio", "dsound", "jack", "null", "opensl", "oss", "pulseaudio", "wasapi", "webaudio", "winmm"}

function main(package)
    local defines = {}
    if not package:config("headeronly") and package:config("shared") then
        table.insert(defines, "MA_DLL")
    end

    local enabled_backends = package:config("enabled_backends")
    if #enabled_backends > 0 then
        table.insert(defines, "MA_ENABLE_ONLY_SPECIFIC_BACKENDS")
        for _, backend in ipairs(enabled_backends) do
            if not available_backends:has(backend) then
                os.raise("unknown backend " .. backend)
            end
            table.insert(defines, "MA_ENABLE_" .. backend:upper())
        end
    end
    local disabled_backends = package:config("disabled_backends")
    for _, backend in ipairs(disabled_backends) do
        for _, backend in ipairs(enabled_backends) do
            if not available_backends:has(backend) then
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
    if package:config("worklets") and package:is_plat("wasm") then
        table.insert(defines, "MA_ENABLE_AUDIO_WORKLETS")
    end
    return table.unique(defines)
end
