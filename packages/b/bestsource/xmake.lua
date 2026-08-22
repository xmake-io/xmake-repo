package("bestsource")
    set_homepage("https://github.com/vapoursynth/bestsource")
    set_description("A super great audio/video source and FFmpeg wrapper")
    set_license("MIT")

    add_urls("https://github.com/vapoursynth/bestsource/archive/refs/tags/R$(version).tar.gz")
    add_urls("https://github.com/vapoursynth/bestsource.git", {alias = "git", submodules = false})

    add_versions("16", "36b035939b6897c68303fc356a7a7d9d37685ce9a102c7a4af955531c1b23be8")

    add_versions("git:16", "R16")

    add_configs("plugin", {description = "Enable AviSynth and VapourSynth plugin", default = false, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_syslinks("shell32")
    end

    add_deps("xxhash", "libp2p", "ffmpeg")

    on_check("windows|arm64", function (package)
        if not package:is_cross() then
            raise("package(bestsource) dep(ffmpeg) unsupported windows arm64 native build, because it require arm64 msys2")
        end
    end)

    on_load(function (package)
        if package:config("plugin") then
            package:add("deps", "avisynthplus", "vapoursynth")
        end
    end)

    on_install("windows", "mingw@windows,linux,cygwin,msys", "linux", "macosx", "android", "iphoneos", function (package)
        io.replace("src/audiosource.cpp", "../libp2p/p2p_api.h", "libp2p/p2p_api.h", {plain = true})
        io.replace("src/videosource.cpp", "../libp2p/p2p_api.h", "libp2p/p2p_api.h", {plain = true})
        io.replace("src/avisynth.cpp", "../AviSynthPlus/avs_core/include/avisynth.h", "avisynth/avisynth.h", {plain = true})
        if package:config("plugin") then
            io.replace("src/synthshared.cpp", '#include "VSHelper4.h"', " #include <vapoursynth/VSHelper4.h>", {plain = true})
            io.replace("src/avisynth.cpp", "VSHelper4.h", "vapoursynth/VSHelper4.h", {plain = true})
            io.replace("src/vapoursynth.cpp", "VSHelper4.h", "vapoursynth/VSHelper4.h", {plain = true})
            io.replace("src/vapoursynth.cpp", "VapourSynth4.h", "vapoursynth/VapourSynth4.h", {plain = true})
        end

        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, {plugin = package:config("plugin")})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(BestVideoSource* bs) {
                bs->GetTrack();
            }
        ]]}, {configs = {languages = "c++17"}, includes = "videosource.h"}))
    end)
