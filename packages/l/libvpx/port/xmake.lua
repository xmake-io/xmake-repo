set_project("libvpx")
set_version("1.13.0")

includes("check_csnippets.lua")
add_moduledirs("xmake/scripts")
add_imports("core.project.project", "rtcd", "utils")
add_rules("asm", "mode.debug", "mode.release")
set_config("buildir", "xmake_build")

option("vp8", function()
    add_deps("vp8-encoder", "vp8-decoder")
    set_description("VP8 codec support")
    set_category("codec")
    set_default(true)
    after_check(function(opt)
        if opt:enabled() then
            if not (opt:dep("vp8-encoder"):enabled() or opt:dep("vp8-decoder"):enabled()) then
                cprint(
                    "${bright yellow}warn${clear}: options vp8-encoder and vp8-decoder are both disabled, force disable option vp8")
            end
        else
            opt:dep("vp8-encoder"):enable(false)
            opt:dep("vp8-decoder"):enable(false)
        end
    end)
end)
option("vp8-encoder", function()
    set_description("VP8 encoder support")
    set_category("codec/vp8")
    set_default(true)
end)
option("vp8-decoder", function()
    set_description("VP8 decoder support")
    set_category("codec/vp8")
    set_default(true)
end)

option("vp9", function()
    add_deps("vp9-encoder", "vp9-decoder")
    set_description("VP9 codec support")
    set_category("codec")
    set_default(true)
    after_check(function(opt)
        if opt:enabled() then
            if not (opt:dep("vp9-encoder"):enabled() or opt:dep("vp9-decoder"):enabled()) then
                cprint(
                    "${bright yellow}warn${clear}: options vp9-encoder and vp9-decoder are both disabled, force disable option vp9")
            end
        else
            opt:dep("vp9-encoder"):enable(false)
            opt:dep("vp9-decoder"):enable(false)
        end
    end)
end)
option("vp9-encoder", function()
    set_description("VP9 encoder support")
    set_category("codec/vp9")
    set_default(true)
end)
option("vp9-decoder", function()
    set_description("VP9 decoder support")
    set_category("codec/vp9")
    set_default(true)
end)

option("encoders", function()
    add_deps("vp8-encoder", "vp9-encoder")
    set_showmenu(false)
    after_check(function(opt)
        opt:enable(opt:dep("vp8-encoder"):enabled() or opt:dep("vp9-encoder"):enabled())
    end)
end)

option("decoders", function()
    add_deps("vp8-decoder", "vp9-decoder")
    set_showmenu(false)
    after_check(function(opt)
        opt:enable(opt:dep("vp8-decoder"):enabled() or opt:dep("vp9-decoder"):enabled())
    end)
end)

option("pic", function()
    set_description("turn on/off Position Independent Code")
    set_default(true)
end)

option("big-endian", function()
    set_description("build for big endian")
    set_default(false)
end)

option("vp9-highbitdepth", function()
    set_description("use VP9 high bit depth (10/12) profiles")
    set_category("vp9")
    set_default(false)
end)

option("internal-stats", function()
    set_description("output of encoder internal stats for debug, if supported (encoders)")
    set_default(is_mode("debug"))
end)

option("postproc", function()
    set_description("postprocessing")
    set_default(false)
end)

option("vp9-postproc", function()
    set_description("vp9 specific postprocessing")
    set_category("vp9")
    set_default(false)
end)

option("multithread", function()
    set_description("multithreaded encoding and decoding")
    set_default(true)
    if not is_plat("windows", "android") then
        add_links("pthread")
    end
end)

option("spatial-resampling", function()
    set_description("spatial sampling (scaling) support")
    set_default(true)
end)

option("realtime-only", function()
    set_description("enable this option while building for real-time encoding")
    set_default(false)
end)

option("onthefly-bitpacking", function()
    set_description("enable on-the-fly bitpacking in real-time encoding")
    set_default(false)
end)

option("error-concealment", function()
    set_description("enable this option to get a decoder which is able to conceal losses")
    set_default(false)
end)

option("coefficient-range-checking", function()
    set_description("enable decoder to check if intermediate transform coefficients are in valid range")
    set_default(false)
end)

option("runtime-cpu-detect", function()
    set_description("runtime cpu detection")
    set_default(true)
end)

option("multi-res-encoding", function()
    set_description("enable multiple-resolution encoding")
    set_default(false)
end)

option("temporal-denoising", function()
    set_description("enable temporal denoising and disable the spatial denoiser")
    set_default(true)
end)

option("vp9-temporal-denoising", function()
    set_description("enable vp9 temporal denoising")
    set_category("vp9")
    set_default(false)
end)

option("webm-io", function()
    set_description("enable input from and output to WebM container")
    set_default(false)
end)

option("libyuv", function()
    set_description("enable libyuv")
    set_default(false)
end)

-- platform extendtions
local arch, enabled_exts
local exts = {
    x86 = {{
        name = "mmx",
        include = "mmintrin.h"
    }, {
        name = "sse",
        include = "xmmintrin.h"
    }, {
        name = "sse2",
        include = "emmintrin.h"
    }, {
        name = "sse3",
        include = "pmmintrin.h"
    }, {
        name = "ssse3",
        include = "tmmintrin.h"
    }, {
        name = "sse4",
        include = "smmintrin.h"
    }, {
        name = "avx",
        flags = is_plat("windows") and {"/arch:AVX"} or {"-mavx"},
        default = false
    }, {
        name = "avx2",
        flags = is_plat("windows") and {"/arch:AVX2"} or {"-mavx2"},
        default = false
    }, {
        name = "avx512",
        flags = is_plat("windows") and {"/arch:AVX512"} or
            {"-mavx512f", "-mavx512cd", "-mavx512bw", "-mavx512dq", "-mavx512vl"},
        default = false
    }},
    arm = {{
        name = "neon",
        include = "arm_neon.h",
        flags = {"-mfpu=neon"}
    }},
    loongarch = {"lsx", "lasx"},
    mips = {"dspr2", {
        name = "mmi",
        flags = {"-mloongson-mmi"}
    }, "msa"},
    ppc = {"vsx"},
    unknown = {}
}

if is_arch("x86") then
    arch = "x86"
elseif is_arch("x64", "x86_64") then
    arch = "x86"
elseif is_arch("arm.*") then
    arch = "arm"
elseif is_arch("aarch64.*") then
    arch = "arm"
elseif is_arch("loongarch.*") then
    arch = "loongarch"
elseif is_arch("mips.*") then
    arch = "mips"
elseif is_arch("ppc.*", "powerpc.*") then
    arch = "ppc"
else
    arch = "unknown"
end

for arch, extlist in pairs(exts) do
    for i, ext in ipairs(extlist) do
        if type(ext) == "string" then
            ext = {
                name = ext
            }
        end
        if not ext.flags then
            ext.flags = {"-m" .. ext.name}
        end
        if type(ext.default) == "nil" then
            ext.default = "detect"
        end
        exts[arch][i] = ext
        option("ext-" .. ext.name, function()
            set_default(ext.default)
            set_description("use " .. ext.name .. " instruction for " .. arch)
            set_values(true, false, "detect")
            set_category("exts/" .. arch)
        end)
    end
end

local common_config

-- all target
add_includedirs("$(buildir)/include", "$(projectdir)")
add_configfiles("xmake/(include/*.h.in)")
configvar_check_csnippets("INLINE=inline", "static inline int function(void) {}", {
    name = "_inline",
    quote = false
})
configvar_check_csnippets("RESTRICT=restrict", "int i = 7; int *restrict a = &i;", {
    name = "_restrict",
    quote = false
})
on_load(function(target)
    if arch == "x86" then
        import("lib.detect.find_tool")
        if find_tool("yasm") then
            target:set("toolchains", "yasm")
        elseif find_tool("nasm") then
            target:set("toolchains", "nasm")
        else
            raise("Neither yasm nor nasm have been found.")
        end
    end
    for _, ext in ipairs(exts[arch]) do
        target:add("options", "ext-" .. ext.name)
    end
    common_config = function(target)
        if arch == "arm" then
            if target:has_cflags("-mfloat-abi=hard") then
                target:add("cxflags", "-mfloat-abi=hard")
            elseif target:has_cflags("-mfloat-abi=softfp") then
                target:add("cxflags", "-mfloat-abi=softfp")
            else
                target:add("cxflags", "-mfloat-abi=soft")
                project.option("ext-neon"):enable(false)
            end
        end

        if not enabled_exts then
            enabled_exts = rtcd.detect_exts(target, exts[arch])
        end
        for _, ext in ipairs(exts[arch]) do
            target:add("options", "ext-" .. ext.name)
            local opt = target:opt("ext-" .. ext.name)
            if opt and opt:value() == true then
                for _, flag in ipairs(ext.flags) do
                    target:add("cxflags", flag)
                end
            end
        end
        for name, opt in pairs(project.options()) do
            if name:startswith("ext-") then
                target:add("defines", "HAVE_" .. name:sub(5):upper():gsub("%.", "_") .. "=" ..
                    (opt:value() == true and "1" or "0"))
            else
                target:add("defines", "CONFIG_" .. name:upper():gsub("%-", "_") .. "=" .. (opt:enabled() and "1" or "0"))
            end
        end

        if arch == "arm" then
            target:add("defines", "HAVE_NEON_ASM=" .. (project.option("ext-neon"):value() == true and "1" or "0"))
        elseif arch == "mips" then
            target:add("defines", "HAVE_MIPS32=" .. (is_arch("mips32.*") and "1" or "0"),
                "HAVE_MIPS64=" .. (is_arch("mips64.*") and "1" or "0"))
        end

        for _, archname in ipairs({"aarch64", "arm", "loongarch", "mips", "ppc", "x86", "x86_64"}) do
            local archtype = arch
            if target:is_arch("x64", "x86_64") then
                archtype = "x86_64"
            elseif target:is_arch("aarch64.*") then
                archtype = "aarch64"
            end
            target:add("defines", "VPX_ARCH_" .. archname:upper() .. "=" .. (archtype == archname and "1" or "0"))
        end
    end
end)

after_clean(function()
    os.rm("$(buildir)/include/**")
end)

target("vp8", function()
    set_kind("object")
    set_enabled(has_config("vp8"))
    add_deps("vpx_ports", "vpx_util")
    add_options("vp8", "vp8-encoder", "vp8-decoder")
    add_files("vp8/*.c", "vp8/common/*.c")
    if not has_config("postproc") then
        remove_files("vp8/common/mfqe.c", "vp8/common/postproc.c")
    end
    if has_config("vp8-encoder") then
        add_files("vp8/encoder/*.c")
        if not has_config("multi-res-encoding") then
            remove_files("vp8/encoder/mr_dissim.c")
        end
    end
    if has_config("vp8-decoder") then
        add_files("vp8/decoder/*.c")
        if not has_config("error-concealment") then
            remove_files("vp8/decoder/error_concealment.c")
        end
    end
    on_config(function(target)
        common_config(target)
        rtcd.genrate(target, arch, enabled_exts, "$(projectdir)/vp8/common/rtcd_defs.pl",
            "$(buildir)/include/vp8_rtcd.h")
        utils.add_arch_files(target, arch, enabled_exts, "vp8/common")
        if has_config("vp8-encoder") then
            utils.add_arch_files(target, arch, enabled_exts, "vp8/encoder")
        end
        if has_config("vp8-decoder") then
        end
    end)
end)

target("vp9", function()
    set_kind("object")
    set_enabled(has_config("vp9"))
    add_deps("vpx_ports", "vpx_util")
    add_options("vp9", "vp9-encoder", "vp9-decoder")
    add_files("vp9/*.c", "vp9/common/*.c")
    if not has_config("vp9-postproc") then
        remove_files("vp9/common/vp9_mfqe.c", "vp9/common/vp9_postproc.c")
    end
    if not has_config("vp9-highbitdepth") then
        remove_files("vp9/**/**highbd**")
    end
    if has_config("vp9-encoder") then
        add_files("vp9/encoder/*.c")
        if not has_config("vp9-temporal-denoising") then
            remove_files("vp9/encoder/vp9_denoiser.c")
        end
    end
    if has_config("vp9-decoder") then
        add_files("vp9/decoder/*.c")
    end
    on_config(function(target)
        common_config(target)
        rtcd.genrate(target, arch, enabled_exts, "$(projectdir)/vp9/common/vp9_rtcd_defs.pl",
            "$(buildir)/include/vp9_rtcd.h")
        utils.add_arch_files(target, arch, enabled_exts, "vp9/common")
        if has_config("vp9-encoder") then
            utils.add_arch_files(target, arch, enabled_exts, "vp9/encoder")
        end
        if has_config("vp9-decoder") then
        end
    end)
end)

target("vpx_dsp", function()
    set_kind("object")
    add_deps("vpx_ports", "vpx_util")
    add_files("vpx_dsp/*.c")
    if not has_config("postproc") then
        remove_files("vpx_dsp/**deblock_**.*", "vpx_dsp/**add_noise_**.*", "vpx_dsp/**post_proc_**.*")
    end
    if not has_config("vp9-highbitdepth") then
        remove_files("vpx_dsp/**/**highbd**")
    end
    on_config(function(target)
        common_config(target)
        rtcd.genrate(target, arch, enabled_exts, "$(projectdir)/vpx_dsp/vpx_dsp_rtcd_defs.pl",
            "$(buildir)/include/vpx_dsp_rtcd.h")
        utils.add_arch_files(target, arch, enabled_exts, "vpx_dsp")
    end)
end)

target("vpx_ports", function()
    set_kind("object")
    if is_arch("x64", "x86", "x86_64") then
        add_files("vpx_ports/x86_abi_support.asm")
    elseif arch ~= "unknown" then
        add_files("vpx_ports/" .. arch .. "_cpudetect.c")
    end
    on_config(function(target)
        common_config(target)
        utils.add_arch_files(target, arch, enabled_exts, "vpx_ports")
    end)
end)

target("vpx_scale", function()
    set_kind("object")
    add_deps("vpx_ports")
    add_files("vpx_scale/*.c")
    on_config(function(target)
        common_config(target)
        rtcd.genrate(target, arch, enabled_exts, "$(projectdir)/vpx_scale/vpx_scale_rtcd.pl",
            "$(buildir)/include/vpx_scale_rtcd.h")
        utils.add_arch_files(target, arch, enabled_exts, "vpx_scale")
    end)
end)

target("vpx_util", function()
    set_kind("object")
    add_files("vpx_util/*.c")
    on_config(function(target)
        common_config(target)
    end)
end)

target("libvpx", function()
    set_kind("$(kind)")
    add_deps("vp8", "vp9", "vpx_dsp", "vpx_ports", "vpx_scale", "vpx_util")
    add_files("vpx/src/*.c")
    add_headerfiles("vpx/*.h", {
        prefixdir = "vpx"
    })
    on_config(function(target)
        common_config(target)
        utils.generate_x86inc_asm("$(buildir)/include/vpx_config.asm")
        if target:is_plat("windows") and target:kind() == "shared" then
            utils.generate_dll_def("libvpx", "$(buildir)/libvpx.def")
            target:add("files", "$(buildir)/libvpx.def")
        end
    end)
end)
