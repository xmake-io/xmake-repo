add_rules("mode.debug", "mode.release")

option("simd", {default = true, description = "Build with simd"})

target("pffft")
    set_kind("$(kind)")
    if not has_config("simd") then
        add_defines("PFFFT_SIMD_DISABLE")
    end
    if is_kind("shared") and is_plat("windows") then
        add_rules("utils.symbols.export_all")
    end
    add_files("fftpack.c", "pffft.c")
    add_headerfiles("fftpack.h", "pffft.h")
    if not is_plat("windows") then
        add_syslinks("m")
    else
        add_defines("_USE_MATH_DEFINES", {public = true})
    end
