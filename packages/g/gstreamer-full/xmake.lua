package("gstreamer-full")
    set_homepage("https://gstreamer.freedesktop.org")
    set_description("GStreamer is a development framework for creating applications like media players, video editors, streaming media broadcasters and so on")
    set_license("LGPL-2.0-or-later")

    add_urls("https://github.com/GStreamer/gstreamer/archive/refs/heads/$(version).zip", {alias = "github"})

    -- Version 1.24 is still being updated, and sha256 may be modified at any time!
    -- add_versions("github:1.24", "c1a8aae02a1384ce5e5cb7c4b30b872b7ebb6958a47755cb98581b0f17aaac43")
    add_versions("github:1.22", "a1a71f9651c61a568d41b550599348ba81754c8e47140f6297e7f8b2445f8a43")
    add_versions("github:1.20", "73b4d086911c2e2fe130a375e449d0ed3e3f895befec5ede345c5b2c2a1175a8")

    add_configs("shared", {description = "shared library.", default = true})

    local opts = {
        -- name            description                         default          ver (only work on this version)
        base            = {des = "Build gst-plugin-base.",     default = true},
        good            = {des = "Build gst-plugin-good.",     default = true},
        ugly            = {des = "Build gst-plugin-ugly.",     default = true},
        bad             = {des = "Build gst-plugin-bad.",      default = true},
        libav           = {des = "Build gst-libav.",           default = false, deps = {"ffmpeg"}},
        devtools        = {des = "Build devtools.",            default = false},
        tools           = {des = "Build command line tools.",  default = false, ver = {"1.22"}},
        ges             = {des = "Build ges.",                 default = false},
        libnice         = {des = "ICE support using libnice.", default = false},
        omx             = {des = "Build gst-omx.",             default = false, ver = {"1.20", "1.22"}},
        python          = {des = "Build gst-python.",          default = false},
        qt5             = {des = "Qt5 toolkit support.",       default = false},
        qt6             = {des = "Qt6 toolkit support.",       default = false, ver = {"1.24"}},
        rs              = {des = "Build gst-rs.",              default = false},
        rtsp_server     = {des = "Build gst-rtsp_server.",     default = false},
        sharp           = {des = "Build gst-sharp.",           default = false},
        vaapi           = {des = "Build gst-vaapi.",           default = false},
        webrtc          = {des = "WebRTC support.",            default = false, ver = {"1.24"}},

        introspection   = {des = "Generate introspection data.", default = false},
        gtk_doc         = {des = "Build gtk_doc.",               default = false},
        doc             = {des = "Build documents.",             default = false},
        examples        = {des = "Build examples.",              default = false},
        tests           = {des = "Build tests.",                 default = false},
        -- gst-examples    = {des = "Build gst-examples subproject.", default = false},
        -- glib-asserts        = {des = "Build tools.",        default = "auto", values = {"auto", "enable", "disable"}, type = "string"},
        -- glib-checks         = {des = "Build tools.",        default = "auto", values = {"auto", "enable", "disable"}, type = "string"},
        -- gobject-cast-checks = {des = "Build tools.",        default = "auto", values = {"auto", "enable", "disable"}, type = "string"},

        gpl = {des = "Allow build of plugins that have (A)GPL-licensed dependencies.", default = false},
        nls = {des = "Enable native language support (translations).",                 default = false},
        orc = {des = "Optimized Inner Loop Runtime Compiler (SIMD).",                  default = false},
        tls = {des = "TLS support using glib-networking.",                             default = false}--,
    }
    local childopts = {
        -- parent_child        meson parent name         description                                     default         deps
        base_gl     = {base = "gst-plugins-base", des = "OpenGL",                                        default = true,  deps = {"opengl", "graphene", "libjpeg", "libpng"}},
        base_ogg    = {base = "gst-plugins-base", des = "ogg parser, muxer, demuxer plugin",             default = true,  deps = {"libogg"}},
        base_opus   = {base = "gst-plugins-base", des = "OPUS audio codec plugin",                       default = true,  deps = {"libopus"}},
        base_pango  = {base = "gst-plugins-base", des = "Pango text rendering and overlay plugin",       default = true,  deps = {"pango"}},
        base_vorbis = {base = "gst-plugins-base", des = "Vorbis audio parser, tagger, and codec plugin", default = true,  deps = {"libvorbis"}},

        good_jpeg   = {base = "gst-plugins-good", des = "JPEG image codec plugin",                  default = true,  deps = {"libjpeg"}},
        good_lame   = {base = "gst-plugins-good", des = "LAME mp3 audio encoder plugin",            default = true,  deps = {"lame"}},
        good_dv     = {base = "gst-plugins-good", des = "Digital video decoder and demuxer plugin", default = false, deps = {"libdv"}},

        ugly_x264   = {base = "gst-plugins-ugly", des = "H.264 video encoder plugin based on libx264 (gpl plugin)", default = false, deps = {"x264"}},

        bad_dash     = {base = "gst-plugins-bad", des = "DASH demuxer plugin",                          default = false, deps = {"libxml2"}},
        bad_fdkaac   = {base = "gst-plugins-bad", des = "Fraunhofer AAC audio codec plugin",            default = false, deps = {"fdk-aac"}},
        bad_iqa      = {base = "gst-plugins-bad", des = "Image quality assessment plugin (gpl plugin)", default = false, deps = {"dssim"}},
        bad_microdns = {base = "gst-plugins-bad", des = "libmicrodns-based device provider",            default = false, deps = {"libmicrodns"}},
        bad_openjpeg = {base = "gst-plugins-bad", des = "JPEG2000 image codec plugin",                  default = false, deps = {"openjpeg"}},
        bad_openh264 = {base = "gst-plugins-bad", des = "H.264 video codec plugin",                     default = false, deps = {"openh264"}},
        bad_vulkan   = {base = "gst-plugins-bad", des = "Vulkan video sink plugin",                     default = false, deps = {"vulkansdk"}},
        bad_x265     = {base = "gst-plugins-bad", des = "HEVC/H.265 video encoder plugin (gpl plugin)", default = false, deps = {"x265"}}--,
    }
    local gplopts = {"ugly_x264", "bad_iqa", "bad_x265"}

    for opt, infos in pairs(opts) do
        add_configs(opt, {description = infos.des, default = infos.default, values = infos.values, type = infos.type or "boolean"})
    end
    for opt, infos in pairs(childopts) do
        add_configs(opt, {description = infos.des, default = infos.default, values = infos.values, type = infos.type or "boolean"})
    end

    if is_plat("linux") then
        add_extsources("pacman::gstreamer", "apt::libgstreamer1.0-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::gstreamer")
    elseif is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::gstreamer")
    end

    add_deps("meson", "ninja")
    if is_plat("windows") then
        add_deps("pkgconf", "winflexbison")
    else
        add_deps("flex", "bison")
    end
    add_deps("glib")

    add_includedirs("include/gstreamer-1.0", "lib/gstreamer-1.0/include")

    on_load(function (package)
        package:addenv("PATH", "lib/gstreamer-1.0", "libexec/gstreamer-1.0") -- plugins and tools path

        -- add plugin's deps
        for opt, infos in pairs(opts) do
            if package:config(opt) and infos.deps then
                package:add("deps", infos.deps)
            end
        end
        for opt, infos in pairs(childopts) do
            if package:config(opt) and infos.deps then
                package:add("deps", infos.deps)
            end
        end

        if not package:config("shared") then
            package:add("defines", "GST_STATIC_COMPILATION")
        end
    end)

    on_check(function (package)
        for opt, infos in pairs(childopts) do
            local parentname = opt:split('_', {plain = true, limit = 2})[1]
            assert((not package:config(opt)) or package:config(parentname), "gstreamer-full's option " .. opt .. " depend on option " .. parentname)
        end
        for _, opt in pairs(gploptions) do
            assert((not package:config(opt)) or package:config("gpl"), "gstreamer-full's option" .. opt .. " depend on option gpl")
        end
    end)

    on_install("windows", "macosx", "linux", "cross", function (package)
        local configs = {
            "-Dgst-examples=disabled"
        }
        table.insert(configs, "-Ddebug=" .. (package:is_debug() and "true" or "false"))
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))

        for opt, infos in pairs(opts) do
            if infos.ver and (not table.contains(infos.ver, package:version_str())) then
                assert(not package:config(opt), "gstreamer-full's option " .. opt .. " not support in version " .. package:version_str())
            else
                table.insert(configs, "-D" .. opt .. "=" .. (package:config(opt) and "enabled" or "disabled"))
            end
        end
        for opt, infos in pairs(childopts) do
            local childname = opt:split('_', {plain = true, limit = 2})[2]
            if infos.ver and (not table.contains(infos.ver, package:version_str())) then
                assert(not package:config(opt), "gstreamer-full's option " .. opt .. " not support in version " .. package:version_str())
            else
                table.insert(configs, "-D" .. infos.base .. ":" .. childname .. "=" .. (package:config(opt) and "enabled" or "disabled"))
            end
        end

        io.replace("subprojects/gst-plugins-good/ext/lame/meson.build", "mp3lame", "lame", {plain = true})
        for _, file in ipairs(os.files("subprojects/gst-plugins-good/ext/lame/*")) do
            io.replace(file, "#include \"lame.h\"", "#include <lame/lame.h>", {plain = true})
        end
        for _, file in ipairs(os.files("subprojects/**/meson.build")) do
            io.replace(file, "libxml-2.0", "libxml2", {plain = true})
        end
        io.replace("subprojects/gst-plugins-bad/ext/openjpeg/meson.build", "libopenjp2", "openjpeg", {plain = true})

        local packagedeps = {}
        if not package:dep("glib"):config("shared") then
            table.insert(packagedeps, "libiconv")
        end
        if package:is_plat("windows", "macosx") then
            table.insert(packagedeps, "libintl")
        end
        import("package.tools.meson").install(package, configs, {packagedeps = packagedeps})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gst_init", {includes = "gst/gst.h"}))
    end)