package("libpng")
    set_homepage("https://www.libpng.org/pub/png/libpng.html")
    set_description("The official PNG reference library")
    set_license("libpng-2.0")

    add_urls("https://github.com/glennrp/libpng/archive/refs/tags/$(version).tar.gz",
             "https://github.com/glennrp/libpng.git")

    add_versions("v1.6.55", "71a2c5b1218f60c4c6d2f1954c7eb20132156cae90bdb90b566c24db002782a6")
    add_versions("v1.6.54", "ba7efce137409079989df4667706c339bebfbb10e9f413474718012a13c8cd4c")
    add_versions("v1.6.53", "b20cee717e11416d2f96ccc7d184f63730ca8cb2f03bfd0c4ed77fbc909c0bff")
    add_versions("v1.6.51", "b1872484c1c5c70acc79cbb15fb366df954fa8d5dacbe7f729d858902d17933c")
    add_versions("v1.6.50", "71158e53cfdf2877bc99bcab33641d78df3f48e6e0daad030afe9cb8c031aa46")
    add_versions("v1.6.49", "e425762fdfb9bb30a5d2da29c0067570e96b5d41d79c659cf0dad861e9df738e")
    add_versions("v1.6.48", "b17e99026055727e8cba99160c3a9a7f9af788e9f786daeadded5a42243f1dd0")
    add_versions("v1.6.47", "631a4c58ea6c10c81f160c4b21fa8495b715d251698ebc2552077e8450f30454")
    add_versions("v1.6.46", "767b01936f9620d4ab4cdf6ec348f6526f861f825648b610b1d604167dc738d2")
    add_versions("v1.6.44", "0ef5b633d0c65f780c4fced27ff832998e71478c13b45dfb6e94f23a82f64f7c")
    add_versions("v1.6.43", "fecc95b46cf05e8e3fc8a414750e0ba5aad00d89e9fdf175e94ff041caf1a03a")
    add_versions("v1.6.42", "fe89de292e223829859d21990d9c4d6b7e30e295a268f6a53a022611aa98bd67")
    add_versions("v1.6.40", "62d25af25e636454b005c93cae51ddcd5383c40fa14aa3dae8f6576feb5692c2")
    add_versions("v1.6.37", "ca74a0dace179a8422187671aee97dd3892b53e168627145271cad5b5ac81307")
    add_versions("v1.6.36", "5bef5a850a9255365a2dc344671b7e9ef810de491bd479c2506ac3c337e2d84f")
    add_versions("v1.6.35", "6d59d6a154ccbb772ec11772cb8f8beb0d382b61e7ccc62435bf7311c9f4b210")
    add_versions("v1.6.34", "e45ce5f68b1d80e2cb9a2b601605b374bdf51e1798ef1c2c2bd62131dfcf9eef")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("zlib")

    if is_plat("linux") then
        add_syslinks("m")
    end

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::libpng")
    elseif is_plat("linux") then
        add_extsources("pacman::libpng", "apt::libpng-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::libpng")
    end

    on_install(function (package)
        if package:is_plat("android") and package:is_arch("armeabi-v7a") then
            io.replace("arm/filter_neon.S", ".func", ".hidden", {plain = true})
            io.replace("arm/filter_neon.S", ".endfunc", "", {plain = true})
        end
        os.cp("scripts/pnglibconf.h.prebuilt", "pnglibconf.h")
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("zlib")
            target("png")
                set_kind("$(kind)")
                add_files("*.c|example.c|pngtest.c")
                if is_arch("x86", "x64", "i386", "x86_64") then
                    add_files("intel/*.c")
                    add_defines("PNG_INTEL_SSE_OPT=1")
                    add_vectorexts("sse", "sse2")
                elseif is_arch("arm.*") then
                    add_files("arm/*.c")
                    if is_plat("windows") then
                        add_defines("PNG_ARM_NEON_OPT=1")
                        add_defines("PNG_ARM_NEON_IMPLEMENTATION=1")
                    else
                        add_files("arm/*.S")
                        add_defines("PNG_ARM_NEON_OPT=2")
                    end
                elseif is_arch("mips.*") then
                    add_files("mips/*.c")
                    add_defines("PNG_MIPS_MSA_OPT=2")
                elseif is_arch("ppc.*") then
                    add_files("powerpc/*.c")
                    add_defines("PNG_POWERPC_VSX_OPT=2")
                end
                add_headerfiles("*.h")
                add_packages("zlib")
                if is_kind("shared") and is_plat("windows") then
                    add_defines("PNG_BUILD_DLL")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("png_create_read_struct", {includes = "png.h"}))
    end)
