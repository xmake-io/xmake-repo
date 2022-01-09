package("libbpg")

    set_homepage("https://bellard.org/bpg/")
    set_description("Image format meant to improve on JPEG quality and file size")

    add_urls("https://bellard.org/bpg/libbpg-$(version).tar.gz")
    add_versions("0.9.8", "c0788e23bdf1a7d36cb4424ccb2fae4c7789ac94949563c4ad0e2569d3bf0095")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    on_install("windows", "macosx", "linux", function (package)
        if package:is_plat("windows") then
            io.replace("libavutil/internal.h", "#pragma comment", "//", {plain = true})
            io.replace("config.h", "#define HAVE_ATOMICS_GCC 1", "#define HAVE_ATOMICS_GCC 0", {plain = true})
            io.replace("config.h", "#define HAVE_ATOMICS_WIN32 0", "#define HAVE_ATOMICS_WIN32 1", {plain = true})
        end
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("libpng")
            target("bpg")
                set_kind("static")
                add_files("libbpg.c")
                add_files("libavcodec/hevc_cabac.c", "libavcodec/hevc_filter.c", "libavcodec/hevc.c", "libavcodec/hevcpred.c", "libavcodec/hevc_refs.c")
                add_files("libavcodec/hevcdsp.c", "libavcodec/hevc_mvs.c", "libavcodec/hevc_ps.c", "libavcodec/hevc_sei.c")
                add_files("libavcodec/utils.c", "libavcodec/cabac.c", "libavcodec/golomb.c", "libavcodec/videodsp.c")
                add_files("libavutil/mem.c", "libavutil/buffer.c", "libavutil/log2_tab.c", "libavutil/frame.c", "libavutil/pixdesc.c", "libavutil/md5.c")
                add_includedirs(".")
                add_headerfiles("libbpg.h")
                add_defines("HAVE_AV_CONFIG_H", "USE_PRED", "USE_VAR_BIT_DEPTH")
                on_load(function (target)
                    local version = io.readfile("VERSION")
                    target:add("defines", "CONFIG_BPG_VERSION=" .. version)
                end)
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("bpg_decoder_open", {includes = "libbpg.h"}))
    end)
