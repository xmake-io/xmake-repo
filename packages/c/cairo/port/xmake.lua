add_rules("mode.debug", "mode.release")
add_requires("zlib", "libpng", "pixman")

option("with_x11")
    set_default(is_plat("linux") and true or false)
    add_defines("CAIRO_HAS_XLIB_SURFACE=1")
option_end()
if has_config("with_x11") then
    add_requires("libxrender")
end

option("with_freetype")
    set_default(is_plat("linux") and true or false)
    add_defines(
        "HAVE_FT_GLYPHSLOT_EMBOLDEN=1",
        "HAVE_FT_LIBRARY_SETLCDFILTER=1",
        "HAVE_FT_GLYPHSLOT_OBLIQUE=1",
        "HAVE_FT_LOAD_SFNT_TABLE=1",
        "HAVE_FT_GET_X11_FONT_FORMAT=1",
        "CAIRO_HAS_FT_FONT=1",
        "CAIRO_HAS_FC_FONT=1"
    )
option_end()
if has_config("with_freetype") then
    add_requires("freetype", "fontconfig")
end

target("cairo")
    set_kind("$(kind)")
    add_packages("zlib", "libpng", "pixman")

    add_includedirs("$(projectdir)")
    add_includedirs("$(projectdir)/src")
    if is_plat("windows") then
        if get_config("kind") == "static" then 
            add_defines("CAIRO_WIN32_STATIC_BUILD=1")
        end
        add_syslinks("gdi32", "msimg32", "user32")
    elseif is_plat("macosx") then
        add_frameworks("CoreGraphics", "CoreFoundation")
    elseif is_plat("linux") then
        add_cxflags("pthread")
    end

    if is_plat("windows") then
        add_includedirs("$(projectdir)/src/win32")
        add_files(
            "src/win32/cairo-win32-debug.c",
            "src/win32/cairo-win32-device.c",
            "src/win32/cairo-win32-gdi-compositor.c",
            "src/win32/cairo-win32-system.c",
            "src/win32/cairo-win32-surface.c",
            "src/win32/cairo-win32-display-surface.c",
            "src/win32/cairo-win32-printing-surface.c",
            "src/win32/cairo-win32-font.c"
        )
    else
        add_defines(
            "HAVE_INTTYPES_H=1",
            "HAVE_STDINT_H=1",
            "HAVE_SYS_TYPES_H=1",
            "HAVE_UINT64_T=1",
            "HAVE_UNISTD_H=1",
            "CAIRO_HAS_PTHREAD=1",
            "CAIRO_HAS_REAL_PTHREAD=1"
        )
    end

    -- set_configvar("FT_ON", has_config("with_freetype") and 1 or 0)
    -- add_configfiles("cairo-features.h.in", {prefixdir = "$(projectdir)"})
    add_headerfiles(
        "src/cairo.h",
        "src/cairo-deprecated.h",
        "src/cairo-pdf.h",
        "src/cairo-ps.h",
        "src/cairo-script.h",
        "src/cairo-svg.h",
        "src/cairo-win32.h",
        "src/cairo-ft.h",
        "src/cairo-xlib.h",
        "cairo-features.h",
        "cairo-version.h",
        "util/cairo-gobject/cairo-gobject.h",
        {prefixdir = "cairo"}
    )
    add_files(
        "src/cairo-analysis-surface.c",
        "src/cairo-arc.c",
        "src/cairo-array.c",
        "src/cairo-atomic.c",
        "src/cairo-base64-stream.c",
        "src/cairo-base85-stream.c",
        "src/cairo-bentley-ottmann.c",
        "src/cairo-bentley-ottmann-rectangular.c",
        "src/cairo-bentley-ottmann-rectilinear.c",
        "src/cairo-botor-scan-converter.c",
        "src/cairo-boxes.c",
        "src/cairo-boxes-intersect.c",
        "src/cairo.c",
        "src/cairo-cache.c",
        "src/cairo-clip.c",
        "src/cairo-clip-boxes.c",
        "src/cairo-clip-polygon.c",
        "src/cairo-clip-region.c",
        "src/cairo-clip-surface.c",
        "src/cairo-color.c",
        "src/cairo-composite-rectangles.c",
        "src/cairo-compositor.c",
        "src/cairo-contour.c",
        "src/cairo-damage.c",
        "src/cairo-debug.c",
        "src/cairo-default-context.c",
        "src/cairo-device.c",
        "src/cairo-error.c",
        "src/cairo-fallback-compositor.c",
        "src/cairo-fixed.c",
        "src/cairo-font-face.c",
        "src/cairo-font-face-twin.c",
        "src/cairo-font-face-twin-data.c",
        "src/cairo-font-options.c",
        "src/cairo-freelist.c",
        "src/cairo-freed-pool.c",
        "src/cairo-gstate.c",
        "src/cairo-hash.c",
        "src/cairo-hull.c",
        "src/cairo-image-compositor.c",
        "src/cairo-image-info.c",
        "src/cairo-image-source.c",
        "src/cairo-image-surface.c",
        "src/cairo-line.c",
        "src/cairo-lzw.c",
        "src/cairo-matrix.c",
        "src/cairo-mask-compositor.c",
        "src/cairo-mesh-pattern-rasterizer.c",
        "src/cairo-mempool.c",
        "src/cairo-misc.c",
        "src/cairo-mono-scan-converter.c",
        "src/cairo-mutex.c",
        "src/cairo-no-compositor.c",
        "src/cairo-observer.c",
        "src/cairo-output-stream.c",
        "src/cairo-paginated-surface.c",
        "src/cairo-path-bounds.c",
        "src/cairo-path.c",
        "src/cairo-path-fill.c",
        "src/cairo-path-fixed.c",
        "src/cairo-path-in-fill.c",
        "src/cairo-path-stroke.c",
        "src/cairo-path-stroke-boxes.c",
        "src/cairo-path-stroke-polygon.c",
        "src/cairo-path-stroke-traps.c",
        "src/cairo-path-stroke-tristrip.c",
        "src/cairo-pattern.c",
        "src/cairo-pen.c",
        "src/cairo-polygon.c",
        "src/cairo-polygon-intersect.c",
        "src/cairo-polygon-reduce.c",
        "src/cairo-raster-source-pattern.c",
        "src/cairo-recording-surface.c",
        "src/cairo-rectangle.c",
        "src/cairo-rectangular-scan-converter.c",
        "src/cairo-region.c",
        "src/cairo-rtree.c",
        "src/cairo-scaled-font.c",
        "src/cairo-shape-mask-compositor.c",
        "src/cairo-slope.c",
        "src/cairo-spans.c",
        "src/cairo-spans-compositor.c",
        "src/cairo-spline.c",
        "src/cairo-stroke-dash.c",
        "src/cairo-stroke-style.c",
        "src/cairo-surface.c",
        "src/cairo-surface-clipper.c",
        "src/cairo-surface-fallback.c",
        "src/cairo-surface-observer.c",
        "src/cairo-surface-offset.c",
        "src/cairo-surface-snapshot.c",
        "src/cairo-surface-subsurface.c",
        "src/cairo-surface-wrapper.c",
        "src/cairo-time.c",
        "src/cairo-tor-scan-converter.c",
        "src/cairo-tor22-scan-converter.c",
        "src/cairo-clip-tor-scan-converter.c",
        "src/cairo-tag-attributes.c",
        "src/cairo-tag-stack.c",
        "src/cairo-toy-font-face.c",
        "src/cairo-traps.c",
        "src/cairo-tristrip.c",
        "src/cairo-traps-compositor.c",
        "src/cairo-unicode.c",
        "src/cairo-user-font.c",
        "src/cairo-version.c",
        "src/cairo-wideint.c",
        -- generic font support
        "src/cairo-cff-subset.c",
        "src/cairo-scaled-font-subsets.c",
        "src/cairo-truetype-subset.c",
        "src/cairo-type1-fallback.c",
        "src/cairo-type1-glyph-names.c",
        "src/cairo-type1-subset.c",
        "src/cairo-type3-glyph-surface.c",
        -- pdf
        "src/cairo-pdf-interchange.c",
        "src/cairo-pdf-operators.c",
        "src/cairo-pdf-shading.c",
        "src/cairo-pdf-surface.c",
        -- png
        "src/cairo-png.c",
        -- ps surface
        "src/cairo-ps-surface.c",
        -- deflate source
        "src/cairo-deflate-stream.c",
        -- svg surface
        "src/cairo-svg-surface.c",
        -- script surface
        "src/cairo-script-surface.c"
    )
    if has_config("with_freetype") then
        add_files("src/cairo-ft-font.c")
        add_packages("freetype", "fontconfig")
    end
target_end()
