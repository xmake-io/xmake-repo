package("ffmpeg")

    set_homepage("https://www.ffmpeg.org")
    set_description("A collection of libraries to process multimedia content such as audio, video, subtitles and related metadata.")

    add_urls("https://ffmpeg.org/releases/ffmpeg-$(version).tar.bz2", {alias = "home"})
    add_urls("https://github.com/FFmpeg/FFmpeg/archive/n$(version).zip", {alias = "github"})
    add_urls("https://git.ffmpeg.org/ffmpeg.git", "https://github.com/FFmpeg/FFmpeg.git")
    add_versions("home:4.0.2", "346c51735f42c37e0712e0b3d2f6476c86ac15863e4445d9e823fe396420d056")
    add_versions("github:4.0.2", "4df1ef0bf73b7148caea1270539ef7bd06607e0ea8aa2fbf1bb34062a097f026")

    add_configs("ffmpeg",  {description = "Enable ffmpeg program.", default = false, type = "boolean"})
    add_configs("ffplay",  {description = "Enable ffplay program.", default = false, type = "boolean"})
    add_configs("zlib",    {description = "Enable zlib compression library.", default = false, type = "boolean"})
    add_configs("libx264", {description = "Enable libx264 decoder.", default = false, type = "boolean"})
    add_configs("libx265", {description = "Enable libx265 decoder.", default = false, type = "boolean"})
    add_configs("iconv",   {description = "Enable libiconv library.", default = false, type = "boolean"})

    add_links("avfilter", "avdevice", "avformat", "avcodec", "swscale", "swresample", "avutil")
    if is_plat("macosx") then
        add_frameworks("CoreFoundation", "Foundation", "CoreVideo", "CoreMedia", "AudioToolbox", "VideoToolbox", "Security")
    end

    on_load(function (package)
        local configdeps = {zlib    = "zlib",
                            libx264 = "x264",
                            libx265 = "x265",
                            iconv   = "libiconv"}
        for name, dep in pairs(configdeps) do
            if package:config(name) then
                package:add("deps", dep)
            end
        end
    end)
  
    on_install("linux", "macosx", function (package)
        local configs = {"--disable-lzma",
                         "--disable-bzlib",
                         "--enable-gpl",
                         "--enable-version3",
                         "--enable-hardcoded-tables",
                         "--enable-avresample"}
        if is_plat("macosx") and macos.version():ge("10.8") then
            table.insert(configs, "--enable-videotoolbox")
        end
        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                if enabled then
                    table.insert(configs, "--enable-" .. name)
                else
                    table.insert(configs, "--disable-" .. name)
                end
            end
        end
        if package:debug() then
            table.insert(configs, "--enable-debug")
        else
            table.insert(configs, "--disable-debug")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("avformat_open_input", {includes = "libavformat/avformat.h"}))
    end)
