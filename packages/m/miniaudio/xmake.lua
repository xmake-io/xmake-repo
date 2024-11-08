package("miniaudio")
    set_homepage("https://miniaud.io")
    set_description("Single file audio playback and capture library written in C.")
    set_license("MIT")

    set_urls("https://github.com/mackron/miniaudio/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mackron/miniaudio.git")
    add_versions("0.11.21", "6afb5c231613d2fab4f1c668b7243ff9a7d6d78a7f5a2692c133f026fe508506")
    add_versions("0.11.15", "24a6d38fe69cd42d91f6c1ad211bb559f6c89768c4671fa05b8027f5601d5457")
    add_versions("0.11.16", "13320464820491c61bd178b95818fecb7cd0e68f9677d61e1345df6be8d4d77e")
    add_versions("0.11.17", "4b139065f7068588b73d507d24e865060e942eb731f988ee5a8f1828155b9480")
    add_versions("0.11.18", "85ca916266d809b39902e180a6d16f82caea9c2ea1cea6d374413641b7ba48c3")

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
        local defines = import("build_defines")(package)
        if #defines > 0 then
            package:add("defines", table.unwrap(defines))
        end
    end)

    on_install(function (package)
        if package:config("headeronly") then
            os.cp("miniaudio.h", package:installdir("include"))
        else
           local defines = import("build_defines")(package)
            if package:is_plat("macosx", "iphoneos") then
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
        local check_snippets = package.check_csnippets
        if package:config("headeronly") and package:is_plat("macosx", "iphoneos") then
            check_snippets = package.check_msnippets
        end
        assert(check_snippets(package, {test = [[
            void test() {
                ma_uint32 major, minor, rev;
                ma_version(&major, &minor, &rev);
            }
        ]]}, {includes = {"miniaudio.h"}, configs = {defines = package:config("headeronly") and "MINIAUDIO_IMPLEMENTATION" or nil}}))
    end)
