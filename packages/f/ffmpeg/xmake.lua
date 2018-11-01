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

    on_load(function (package)
        package:addvar("links", "avfilter", "avdevice", "avformat", "avcodec", "swscale", "swresample", "avutil")
    end)

    on_install("linux", "macosx", function (package)
        local configs = {"--disable-ffmpeg", 
                         "--disable-ffplay", 
                         "--disable-debug", 
                         "--enable-gpl",
                         "--enable-version3",
                         "--enable-hardcoded-tables",
                         "--enable-avresample"}
        local cc = get_config("cc")
        if cc then
            table.insert(configs, "--cc=" .. cc)
        end
        local cflags = get_config("cflags")
        if cflags then
            table.insert(configs, "--host-cflags=" .. cflags)
        end
        if is_plat("macosx") and macos.version():ge("10.8") then
            table.insert(configs, "--enable-videotoolbox")
        end
        if package:config("x264") ~= false and package:dep("x264"):exists() then
            table.insert(configs, "--enable-libx264")
        end
        if package:config("x265") ~= false and package:dep("x265"):exists() then
            table.insert(configs, "--enable-libx265")
        end
        import("package.tools.autoconf").install(package, configs)
    end)
