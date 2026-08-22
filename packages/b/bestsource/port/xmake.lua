option("plugin", {default = false})

add_requires("xxhash", "libp2p", "ffmpeg")
if has_config("plugin") then
    add_requires("avisynthplus", "vapoursynth")
end

add_rules("mode.release", "mode.debug")

set_languages("c++17")

target("bestsource")
    set_kind("$(kind)")
    add_files(
        "src/audiosource.cpp",
        "src/bsshared.cpp",
        "src/tracklist.cpp",
        "src/videosource.cpp"
    )
    add_headerfiles(
        "src/audiosource.h",
        "src/bsshared.h",
        "src/tracklist.h",
        "src/version.h",
        "src/videosource.h"
    )
    if has_config("plugin") then
        add_files(
            "src/avisynth.cpp",
            "src/synthshared.cpp",
            "src/vapoursynth.cpp"
        )
        add_packages("avisynthplus", "vapoursynth")
    end
    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all", {export_classes = true})
    end
    if is_plat("windows", "mingw") then
        add_syslinks("shell32")
    end
    add_packages("xxhash", "libp2p", "ffmpeg")
