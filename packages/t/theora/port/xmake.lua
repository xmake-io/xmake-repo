set_project("theora")
set_kind("$(kind)")

add_rules("mode.debug", "mode.release")
if is_plat("windows") and is_kind("shared") then
     add_rules("utils.symbols.export_all")
end

add_requires("libogg")

add_packages("libogg")
add_includedirs("include")
add_headerfiles("include/(theora/*.h)")
set_warnings("all")

target("theoraenc")
    add_files("lib/apiwrapper.c",
              "lib/fragment.c",
              "lib/idct.c",
              "lib/internal.c",
              "lib/info.c",
              "lib/state.c",
              "lib/quant.c",
              "lib/analyze.c",
              "lib/encfrag.c",
              "lib/encapiwrapper.c",
              "lib/encinfo.c",
              "lib/encode.c",
              "lib/enquant.c",
              "lib/fdct.c",
              "lib/huffenc.c",
              "lib/mathops.c",
              "lib/mcenc.c",
              "lib/rate.c",
              "lib/tokenize.c")
    local asmdir = is_plat("windows") and "x86_vc" or "x86"
    if is_arch("x86") then
        add_defines("OC_X86_ASM")
        add_files(path.join("lib", asmdir, "*.c|sse2fdct.c"))
    elseif is_arch("x64", "x86_64") and not is_plat("windows") then
        add_defines("OC_X86_ASM", "OC_X86_64_ASM")
        add_files(path.join("lib", asmdir, "*.c"))
    end

target("theoradec")
    add_files("lib/apiwrapper.c",
	          "lib/bitpack.c",
              "lib/decapiwrapper.c",
              "lib/decinfo.c",
              "lib/decode.c",
              "lib/dequant.c",
              "lib/fragment.c",
              "lib/huffdec.c",
              "lib/idct.c",
              "lib/info.c",
              "lib/internal.c",
              "lib/quant.c",
              "lib/state.c")
    local asmdir = is_plat("windows") and "x86_vc" or "x86"
    if is_arch("x86") or (not is_plat("windows") and is_arch("x64", "x86_64")) then
        add_defines("OC_X86_ASM")
        add_files(path.join("lib", asmdir, "mmxidct.c"),
                  path.join("lib", asmdir, "mmxfrag.c"),
                  path.join("lib", asmdir, "mmxstate.c"),
                  path.join("lib", asmdir, "x86state.c"))
        if os.exists("lib", asmdir, "sse2idct.c") then
            add_files("lib", asmdir, "sse2idct.c")
        end
        if os.exists(path.join("lib", asmdir, "x86cpu.c")) then
            add_files(path.join("lib", asmdir, "x86cpu.c"))
        end
        if is_arch("x64", "x86_64") then
            add_defines("OC_X86_64_ASM")
        end
    end
