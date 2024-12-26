add_rules("mode.debug", "mode.release")

option("nosimd")
    set_default(false)
    set_description("Build without SIMD support.")
    add_defines("PFFFT_SIMD_DISABLE")

target("pffft")
    set_kind("$(kind)")
    add_options("nosimd")
    if is_kind("shared") then
        add_rules("utils.symbols.export_all")
    end
    add_files("*.c")
    add_headerfiles("*.h")
    if not is_plat("windows") then
        add_syslinks("m")
    else
        add_defines("_USE_MATH_DEFINES", {public = true})
    end
