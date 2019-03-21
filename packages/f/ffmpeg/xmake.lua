package("ffmpeg")

    set_homepage("https://www.ffmpeg.org")
    set_description("A collection of libraries to process multimedia content such as audio, video, subtitles and related metadata.")

    add_urls("https://ffmpeg.org/releases/ffmpeg-$(version).tar.bz2", {alias = "home"})
    add_urls("https://github.com/FFmpeg/FFmpeg/archive/n$(version).zip", {alias = "github"})
    add_urls("https://git.ffmpeg.org/ffmpeg.git", "https://github.com/FFmpeg/FFmpeg.git")
    add_versions("home:4.0.2", "346c51735f42c37e0712e0b3d2f6476c86ac15863e4445d9e823fe396420d056")
    add_versions("github:4.0.2", "4df1ef0bf73b7148caea1270539ef7bd06607e0ea8aa2fbf1bb34062a097f026")

    add_deps("x264", {optional = true})
    add_deps("x265", {optional = true})

    add_links("avfilter", "avdevice", "avformat", "avcodec", "swscale", "swresample", "avutil")

    add_configs("libx264", {description = "Enable libx264 decoder.", default = false, type = "boolean"})
    add_configs("libx265", {description = "Enable libx265 decoder.", default = false, type = "boolean"})

    if is_plat("macosx") then
        add_frameworks("CoreFoundation", "Foundation", "CoreVideo", "CoreMedia", "AudioToolbox", "VideoToolbox", "Security")
    end
 
    on_install("linux", "macosx", function (package)
        local configs = {"--disable-ffmpeg", 
                         "--disable-ffplay", 
                         "--disable-debug", 
                         "--disable-lzma",
                         "--disable-iconv",
                         "--disable-bzlib",
                         "--disable-zlib",
                         "--enable-gpl",
                         "--enable-version3",
                         "--enable-hardcoded-tables",
                         "--enable-avresample"}
        if is_plat("macosx") and macos.version():ge("10.8") then
            table.insert(configs, "--enable-videotoolbox")
        end
        if package:config("libx264") and package:dep("x264"):exists() then
            table.insert(configs, "--enable-libx264")
        end
        if package:config("libx265") and package:dep("x265"):exists() then
            table.insert(configs, "--enable-libx265")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("avformat_open_input", {includes = "libavformat/avformat.h"}))
    end)
