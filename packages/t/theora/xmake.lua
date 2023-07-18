package("theora")
    set_homepage("https://theora.org/")
    set_description("Reference implementation of the Theora video compression format.")
    set_license("BSD-3-Clause")

    add_urls("https://gitlab.xiph.org/xiph/theora.git",
             "https://gitlab.xiph.org/xiph/theora/-/archive/v$(version)/theora-v$(version).tar.gz",
             "https://github.com/xiph/theora.git")

    add_versions("1.0", "bfaaa9dc04b57b44a3152c2132372c72a20d69e5fc6c9cc8f651cc1bc2434006")
    add_versions("1.1.0", "726e6e157f711011f7377773ce5ee233f7b73a425bf4ad192e4f8a8a71cf21d6")
    add_versions("1.1.1", "316ab9438310cf65c38aa7f5e25986b9d27e9aec771668260c733817ecf26dff")

    add_deps("libogg")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    on_install(function (package)
        io.writefile("xmake.lua", [[set_project("theora")
set_kind("$(kind)")
add_rules("mode.debug", "mode.release")
add_requires("libogg")
add_packages("libogg")
add_includedirs("include")
add_headerfiles("include/(theora/*.h)")
add_cflags("-g", "-O3", "-Wall", "-Wno-parentheses")
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
        add_files("lib/" .. asmdir .. "/*.c|sse2fdct.c")
    elseif is_arch("x64", "x86_64") and not is_plat("windows") then
        add_defines("OC_X86_ASM", "OC_X86_64_ASM")
        add_files("lib/" .. asmdir .. "/*.c")
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
    if is_arch("x86") or (not is_plat("windows") and is_arch("x86", "x86_64")) then
        add_defines("OC_X86_ASM")
        add_files("lib/" .. asmdir .. "/mmxidct.c",
                  "lib/" .. asmdir .. "/mmxfrag.c",
                  "lib/" .. asmdir .. "/mmxstate.c",
                  "lib/" .. asmdir .. "/x86state.c")
        if os.exists("lib/" .. asmdir .. "/sse2idct.c") then
            add_files("lib/" .. asmdir .. "/sse2idct.c")
        end
        if os.exists("lib/" .. asmdir .. "/x86cpu.c") then
            add_files("lib/" .. asmdir .. "/x86cpu.c")
        end
        if is_arch("x64", "x86_64") then
            add_defines("OC_X86_64_ASM")
        end
    end]])
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        elseif not package:is_plat("windows", "mingw") and package:config("pic") ~= false then
            configs.cxflags = "-fPIC"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("theora_encode_init", {includes = "theora/theora.h"}))
    end)
