set_project("libvpx")
set_version("1.13.0")

includes("check_csnippets.lua")
add_moduledirs("xmake/scripts")
add_imports("core.project.project", "lib.detect.find_tool", "rtcd", "utils")
add_rules("asm", "mode.debug", "mode.release")
set_languages("gnu89")
set_config("buildir", "xmake_build")

local arch, fullarch
if is_arch("x86") then
    arch = "x86"
    fullarch = "x86"
elseif is_arch("x64", "x86_64") then
    arch = "x86"
    fullarch = "x86_64"
elseif is_arch("aarch64.*", "armv8.*") then
    arch = "arm"
    fullarch = "aarch64"
elseif is_arch("arm.*") then
    arch = "arm"
    fullarch = "arm"
elseif is_arch("loongarch.*") then
    arch = "loongarch"
    fullarch = "loongarch"
elseif is_arch("mips.*") then
    arch = "mips"
    fullarch = "mips"
elseif is_arch("ppc.*", "powerpc.*") then
    arch = "ppc"
    fullarch = "ppc"
else
    arch = "unknown"
    fullarch = ""
end

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
    on_check(function(opt)
        opt:enable(opt:dep("vp8-encoder"):enabled() or opt:dep("vp9-encoder"):enabled())
    end)
end)

option("decoders", function()
    add_deps("vp8-decoder", "vp9-decoder")
    set_showmenu(false)
    on_check(function(opt)
        opt:enable(opt:dep("vp8-decoder"):enabled() or opt:dep("vp9-decoder"):enabled())
    end)
end)

option("pic", function()
    set_description("turn on/off Position Independent Code")
    set_default(true)
    add_cxflags("-fPIC")
    after_check(function(opt)
        if vformat("$(kind)") == "shared" then
            opt:enable(true)
        end
    end)
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
    add_defines("HAVE_PTHREAD_H")
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
    after_check(function(opt)
        if arch == "unknown" then
            opt:enable(false)
        end
    end)
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

local exts = {
    x86 = {{
        name = "mmx",
        default = fullarch == "x86_64" or "detect"
    }, {
        name = "sse",
        default = fullarch == "x86_64" or "detect"
    }, {
        name = "sse2",
        default = fullarch == "x86_64" or "detect"
    }, "sse3", "ssse3", {
        name = "sse4",
        flags = is_plat("windows") and {"/d2archSSE42"} or {"-msse4"}
    }, "avx", "avx2", {
        name = "avx512",
        flags = is_plat("windows") and {"/arch:AVX512"} or
            {"-mavx512f", "-mavx512cd", "-mavx512bw", "-mavx512dq", "-mavx512vl"}
    }},
    arm = {{
        name = "neon",
        flags = {"-mfpu=neon"},
        default = fullarch == "aarch64" or "detect"
    }, {
        name = "neon_asm",
        flags = {"-mfpu=neon"},
        default = fullarch == "aarch64" or "detect"
    }},
    loongarch = {"lsx", "lasx"},
    mips = {"dspr2", {
        name = "mmi",
        flags = {"-mloongson-mmi"}
    }, "msa"},
    ppc = {"vsx"},
    unknown = {}
}

for _arch, _exts in pairs(exts) do
    for i, ext in ipairs(_exts) do
        if type(ext) == "string" then
            ext = {
                name = ext
            }
        end
        if not ext.flags then
            ext.flags = is_plat("windows") and {"/arch:" .. ext.name:upper()} or {"-m" .. ext.name}
        end
        if type(ext.default) == "nil" then
            ext.default = "detect"
        end
        exts[_arch][i] = ext
        option("ext-" .. ext.name, function()
            add_deps("runtime-cpu-detect")
            set_default(ext.default)
            set_description("enable " .. ext.name .. " instruction for " .. _arch)
            set_values(true, false, "detect")
            set_category("exts/" .. _arch)
            after_check(function(opt)
                if opt:value() == "detect" and opt:dep("runtime-cpu-detect"):enabled() then
                    opt:add("cxflags", table.unpack(ext.flags))
                elseif opt:value() == true then
                    opt:add("cxflags", table.unpack(ext.flags))
                end
            end)
        end)
        if _arch == arch then
            add_options("ext-" .. ext.name)
        end
    end
end

local common_config

-- all target
add_includedirs("$(buildir)/include", "$(projectdir)")
add_configfiles("xmake/(include/vpx_version.h.in)")
if not is_plat("windows", "android") and has_config("multithread") then
    add_syslinks("pthread")
end
if not is_plat("windows") then
    add_syslinks("m")
end
add_options("pic")
on_load(function(target)
    if arch == "x86" then
        if find_tool("yasm") then
            target:set("toolchains", "yasm")
        elseif find_tool("nasm") then
            target:set("toolchains", "nasm")
        else
            raise("Neither yasm nor nasm have been found.")
        end
    end
    common_config = function(target)
        if arch == "arm" then
            if target:has_cflags("-mfloat-abi=hard") then
                target:add("cxflags", "-mfloat-abi=hard")
            elseif target:has_cflags("-mfloat-abi=softfp") then
                target:add("cxflags", "-mfloat-abi=softfp")
            else
                target:add("cxflags", "-mfloat-abi=soft")
            end
        end
    end
end)

after_clean(function()
    os.tryrm("$(buildir)/include/**")
    os.tryrm("$(buildir)/libvpx.def")
end)

target("vp8", function()
    set_kind("object")
    set_enabled(has_config("vp8"))
    add_deps("vpx_ports", "vpx_util")
    add_options("vp8", "vp8-encoder", "vp8-decoder")
    add_files("vp8/*.c", "vp8/common/*.c")
    if arch == "x86" then
        add_files("vp8/common/x86/vp8_asm_stubs.c")
    end
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
        rtcd.generate(target, arch, fullarch, exts, "$(projectdir)/vp8/common/rtcd_defs.pl",
            "$(buildir)/include/vp8_rtcd.h")
        utils.add_arch_files(target, "vp8/common", arch, fullarch, exts)
        if has_config("vp8-encoder") then
            utils.add_arch_files(target, "vp8/encoder", arch, fullarch, exts)
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
    if not has_config("internal-stats") then
        remove_files("vp9/encoder/vp9_blockiness.c")
    end
    if not has_config("vp9-postproc") then
        remove_files("vp9/common/vp9_mfqe.c", "vp9/common/vp9_postproc.c")
    end
    if not has_config("vp9-highbitdepth") then
        remove_files("vp9/**/**highbd**")
    end
    if has_config("vp9-encoder") then
        add_files("vp9/encoder/*.c")
        if not has_config("vp9-temporal-denoising") then
            remove_files("vp9/**/**denoiser**")
        end
    end
    if has_config("vp9-decoder") then
        add_files("vp9/decoder/*.c")
    end
    on_config(function(target)
        common_config(target)
        rtcd.generate(target, arch, fullarch, exts, "$(projectdir)/vp9/common/vp9_rtcd_defs.pl",
            "$(buildir)/include/vp9_rtcd.h")
        utils.add_arch_files(target, "vp9/common", arch, fullarch, exts)
        if has_config("vp9-encoder") then
            utils.add_arch_files(target, "vp9/encoder", arch, fullarch, exts)
        end
        if has_config("vp9-decoder") then
        end
    end)
end)

target("vpx_dsp", function()
    set_kind("object")
    add_deps("vpx_ports", "vpx_util")
    add_files("vpx_dsp/*.c")
    if not has_config("internal-stats") then
        remove_files("vpx_dsp/ssim.c", "vpx_dsp/psnrhvs.c", "vpx_dsp/fastssim.c")
    end
    if not has_config("postproc") then
        remove_files("vpx_dsp/**deblock_**.*", "vpx_dsp/**add_noise_**.*", "vpx_dsp/**post_proc_**.*")
    end
    if not has_config("vp9-highbitdepth") then
        remove_files("vpx_dsp/**/**highbd**")
    end
    on_config(function(target)
        common_config(target)
        rtcd.generate(target, arch, fullarch, exts, "$(projectdir)/vpx_dsp/vpx_dsp_rtcd_defs.pl",
            "$(buildir)/include/vpx_dsp_rtcd.h")
        utils.add_arch_files(target, "vpx_dsp", arch, fullarch, exts)
    end)
end)

target("vpx_mem", function()
    set_kind("object")
    add_files("vpx_mem/*.c")
    on_config(function(target)
        common_config(target)
    end)
end)

target("vpx_ports", function()
    set_kind("object")
    if is_arch("x64", "x86", "x86_64") then
        add_files("vpx_ports/x86_abi_support.asm", "vpx_ports/float_control_word.asm")
        if has_config("ext-mmx") then
            if is_arch("x86") then
                add_files("vpx_ports/emms_mmx.c")
            else
                add_files("vpx_ports/emms_mmx.asm")
            end
        end
    elseif arch == "arm" then
        if is_arch("aarch64.*", "armv8.*") then
            add_files("vpx_ports/aarch64_cpudetect.c")
        else
            add_files("vpx_ports/aarch32_cpudetect.c")
        end
    elseif arch ~= "unknown" then
        add_files("vpx_ports/" .. arch .. "_cpudetect.c")
    end
    on_config(function(target)
        common_config(target)
    end)
end)

target("vpx_scale", function()
    set_kind("object")
    add_deps("vpx_ports")
    add_files("vpx_scale/*.c")
    on_config(function(target)
        common_config(target)
        rtcd.generate(target, arch, fullarch, exts, "$(projectdir)/vpx_scale/vpx_scale_rtcd.pl",
            "$(buildir)/include/vpx_scale_rtcd.h")
        utils.add_arch_files(target, "vpx_scale", arch, fullarch, exts)
    end)
end)

target("vpx_util", function()
    set_kind("object")
    add_files("vpx_util/*.c")
    on_config(function(target)
        common_config(target)
    end)
end)

target("vpx", function()
    set_kind("$(kind)")
    add_deps("vp8", "vp9", "vpx_dsp", "vpx_mem", "vpx_ports", "vpx_scale", "vpx_util")
    add_files("vpx/src/*.c")
    add_headerfiles("vpx/*.h", {
        prefixdir = "vpx"
    })
    on_config(function(target)
        common_config(target)
        utils.generate_vpx_config_h("$(buildir)/include/vpx_config.h", target, fullarch)
        if target:is_arch("x64", "x86", "x86_64") then
            utils.generate_vpx_config_asm("$(buildir)/include/vpx_config.asm", target, fullarch)
        end
        if target:is_plat("windows") and target:kind() == "shared" then
            utils.generate_dll_def("libvpx", "$(buildir)/libvpx.def")
            target:add("files", "$(buildir)/libvpx.def")
        end
    end)
end)
