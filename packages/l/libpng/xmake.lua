package("libpng")
    set_homepage("http://www.libpng.org/pub/png/libpng.html")
    set_description("The official PNG reference library")
    set_license("libpng-2.0")

    set_urls("https://github.com/glennrp/libpng/archive/$(version).zip",
             "https://github.com/glennrp/libpng.git")
    add_versions("v1.6.40", "ab3f88779f0661bbb07c60e778fda782216bff70355d86848fbf6a327084563a")
    add_versions("v1.6.37", "c2c50c13a727af73ecd3fc0167d78592cf5e0bca9611058ca414b6493339c784")
    add_versions("v1.6.36", "6274d3f761cc80f7f6e2cde6c07bed10c00bc4ddd24c4f86e25eb51affa1664d")
    add_versions("v1.6.35", "3d22d46c566b1761a0e15ea397589b3a5f36ac09b7c785382e6470156c04247f")
    add_versions("v1.6.34", "7ffa5eb8f9f3ed23cf107042e5fec28699718916668bbce48b968600475208d3")

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

    on_install("windows", "mingw", "android", "iphoneos", "cross", "bsd", "wasm", function (package)
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
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        elseif not package:is_plat("windows", "mingw") and package:config("pic") ~= false then
            configs.cxflags = "-fPIC"
        end
        if package:is_plat("android") and package:is_arch("armeabi-v7a") then
            io.replace("arm/filter_neon.S", ".func", ".hidden", {plain = true})
            io.replace("arm/filter_neon.S", ".endfunc", "", {plain = true})
        end
        os.cp("scripts/pnglibconf.h.prebuilt", "pnglibconf.h")
        import("package.tools.xmake").install(package, configs)
    end)

    on_install("macosx", "linux", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        local cppflags = {}
        local ldflags = {}
        for _, dep in ipairs(package:orderdeps()) do
            local fetchinfo = dep:fetch()
            if fetchinfo then
                for _, includedir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                    table.insert(cppflags, "-I" .. includedir)
                end
                for _, linkdir in ipairs(fetchinfo.linkdirs) do
                    table.insert(ldflags, "-L" .. linkdir)
                end
            end
        end
        import("package.tools.autoconf").install(package, configs, {cppflags = cppflags, ldflags = ldflags})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("png_create_read_struct", {includes = "png.h"}))
    end)
