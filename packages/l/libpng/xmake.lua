package("libpng")
    set_homepage("http://www.libpng.org/pub/png/libpng.html")
    set_description("The official PNG reference library")
    set_license("libpng-2.0")

    add_urls("https://github.com/glennrp/libpng/archive/refs/tags/$(version).tar.gz",
             "https://github.com/glennrp/libpng.git")

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
    add_versions("v1.2.56", "dadb07d7d96c20f2b53b923b582b078821423f356c0bd52d9a7c14e5e2eafb87")

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
        local src_include
        if package:version() and package:version():le("v1.2.56") then
            src_include = [[
                add_defines("LIBPNG_NO_MMX")
                add_defines("PNG_NO_MMX_CODE")
                if is_plat("windows") then
                    add_defines("PNG_NO_MODULEDEF")
                    add_defines("_CRT_SECURE_NO_DEPRECATE")
                end
            ]]
        else
            src_include = [[
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
            ]]
            if package:is_plat("android") and package:is_arch("armeabi-v7a") then
                io.replace("arm/filter_neon.S", ".func", ".hidden", {plain = true})
                io.replace("arm/filter_neon.S", ".endfunc", "", {plain = true})
            end
            os.cp("scripts/pnglibconf.h.prebuilt", "pnglibconf.h")
        end
        io.writefile("xmake.lua", format([[
            add_rules("mode.debug", "mode.release")
            add_requires("zlib")
            target("png")
                set_kind("$(kind)")
                add_files("*.c|example.c|pngtest.c")
                %s
                add_headerfiles("*.h")
                add_packages("zlib")
                if is_kind("shared") and is_plat("windows") then
                    add_defines("PNG_BUILD_DLL")
                end
        ]], src_include))
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("png_create_read_struct", {includes = "png.h"}))
    end)
