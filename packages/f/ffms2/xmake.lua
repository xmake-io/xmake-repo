package("ffms2")
    set_homepage("https://github.com/FFMS/ffms2")
    set_description("An FFmpeg based source library and Avisynth/VapourSynth plugin for easy frame accurate access")
    set_license("MIT")

    add_urls("https://github.com/FFMS/ffms2/archive/refs/tags/$(version).tar.gz",
             "https://github.com/FFMS/ffms2.git")

    add_versions("5.0", "7770af0bbc0063f9580a6a5c8e7c51f1788f171d7da0b352e48a1e60943a8c3c")

    add_configs("avisynth", {description = "Enable avisynth support", default = false, type = "boolean"})
    add_configs("vapoursynth", {description = "Enable vapoursynth support", default = false, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    add_deps("zlib", "ffmpeg")

    on_check("windows|arm64", function (package)
        if not package:is_cross() then
            raise("package(ffms2) dep(ffmpeg) unsupported windows arm64 native build, because it require arm64 msys2")
        end
    end)

    on_load(function (package)
        if package:config("avisynth") then
            package:add("deps", "avisynthplus")
        end
        if package:config("vapoursynth") then
            package:add("deps", "vapoursynth")
        end
        if not package:config("shared") then
            package:add("defines", "FFMS_STATIC")
        end
    end)

    on_install("windows", "mingw@windows,linux,cygwin,msys", "linux", "macosx", "android", "iphoneos", function (package)
        io.replace("src/avisynth/avssources.h", "avisynth.h", "avisynth/avisynth.h", {plain = true})

        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, {
            avisynth = package:config("avisynth"),
            vapoursynth = package:config("vapoursynth"),
            tools = package:config("tools"),
        })
    end)

    on_test(function (package)
        assert(package:has_cfuncs("FFMS_Init", {includes = "ffms.h"}))
    end)
