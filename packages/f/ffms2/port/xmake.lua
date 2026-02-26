option("tools", {default = false})
option("avisynth", {default = false})
option("vapoursynth", {default = false})

add_rules("mode.debug", "mode.release")

add_languages("c++11")

add_requires("zlib", "ffmpeg")
if has_config("avisynth") then
    add_requires("avisynthplus")
end
if has_config("vapoursynth") then
    add_requires("vapoursynth")
end

add_defines("__STDC_CONSTANT_MACROS")

target("ffms2")
    set_kind("$(kind)")
    add_includedirs("include", {public = true})
    add_files("src/core/*.cpp")
    add_headerfiles("include/*.h")
    if has_config("avisynth") then
        add_files("src/avisynth/*.cpp")
        add_packages("avisynthplus")
    end
    if has_config("vapoursynth") then
        add_files("src/vapoursynth/*.cpp")
        add_packages("vapoursynth")
    end

    if is_kind("static") then
        add_defines("FFMS_STATIC", {public = true})
    elseif is_kind("shared") then
        add_defines("FFMS_EXPORTS")
    end

    add_packages("zlib")
    add_packages("ffmpeg", {public = true})

target("ffmsindex")
    set_enabled(has_config("tools"))
    set_kind("binary")
    add_files("src/index/ffmsindex.cpp")
    if is_plat("windows") then
        add_files("src/index/ffmsindex.manifest")
    end
    add_deps("ffms2")
