package("libpng")
    set_homepage("http://www.libpng.org/pub/png/libpng.html")
    set_description("The official PNG reference library")
    set_license("libpng-2.0")

    
    add_urls("https://github.com/glennrp/libpng/archive/refs/tags/$(version).tar.gz")
    add_urls("https://mirrors.ustc.edu.cn/debian/pool/main/libp/libpng1.6/libpng1.6_$(version).orig.tar.gz", {
        version = function (version) return version:sub(2) end
    })
    add_urls("https://github.com/glennrp/libpng.git")

    add_versions("v1.6.40", "62d25af25e636454b005c93cae51ddcd5383c40fa14aa3dae8f6576feb5692c2")
    add_versions("v1.6.37", "ca74a0dace179a8422187671aee97dd3892b53e168627145271cad5b5ac81307")
    add_versions("v1.6.36", "5bef5a850a9255365a2dc344671b7e9ef810de491bd479c2506ac3c337e2d84f")
    add_versions("v1.6.35", "6d59d6a154ccbb772ec11772cb8f8beb0d382b61e7ccc62435bf7311c9f4b210")
    add_versions("v1.6.34", "e45ce5f68b1d80e2cb9a2b601605b374bdf51e1798ef1c2c2bd62131dfcf9eef")

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
