package("skia")
    set_homepage("https://skia.org/")
    set_description("A complete 2D graphic library for drawing Text, Geometries, and Images.")
    set_license("BSD-3-Clause")

    local commits = {
        ["88"] = "158dc9d7d4cafb177b99b68c5dc502f8f4282092",
        ["89"] = "109bfc9052ce1bde7acf07321d605601d7b7ec24",
        ["90"] = "adbb69cd7fe4e1c321e1526420e30265655e809c",
        ["132"] = "07f41bcb8ee32fd84ae845095d49055d5122e606",
    }
    add_urls("https://github.com/google/skia/archive/$(version).zip", {version = function (version) return commits[tostring(version)] end})

    add_versions("88", "3334fd7d0705e803fe2dd606a2a7d67cc428422a3e2ba512deff84a4bc5c48fa")
    add_versions("89", "b4c8260ad7d1a60e0382422d76ea6174fc35ce781b01030068fcad08364dd334")
    add_versions("90", "5201386a026d1dd55e662408acf9df6ff9d8c1df24ef6a5b3d51b006b516ac90")
    add_versions("132", "1246975f106a2fc98a167bf5d56053a6e8618e42db0394228c6f152daa298116")

    local components = {"gpu", "pdf", "nvpr"}
    for _, component in ipairs(components) do
        add_configs(component, {description = "Enable " .. component .. " support.", default = true, type = "boolean"})
    end

    if is_plat("windows") then
        add_syslinks("gdi32", "user32", "opengl32")
    elseif is_plat("macosx") then
        add_frameworks("CoreFoundation", "CoreGraphics", "CoreText", "CoreServices")
    elseif is_plat("linux") then
        add_syslinks("pthread", "GL", "dl", "rt")
    end

    add_includedirs("include", "include/..", "include/ports")

    add_links("skia")

    add_deps("gn", "python", "ninja", {kind = "binary"})
    if is_plat("linux") then
        add_deps("fontconfig", "freetype >=2.10")
    end

    if on_check then
        on_check(function (package)
            if package:is_cross() then
                raise("package(skia) unsupported cross-compilation now.")
            end
        end)
    end

    on_install("macosx", "linux", "windows", function (package)
        local args = {is_official_build = false,
                      is_component_build = false,
                      is_debug = package:debug(),
                      is_shared_library = package:config("shared"),
                      skia_enable_tools = false,
                      skia_use_icu = false,
                      skia_use_sfntly = true,
                      skia_use_piex = true,
                      skia_use_freetype = true,
                      skia_use_system_freetype2 = package:is_plat("linux") and true or false,
                      skia_use_harfbuzz = true,
                      skia_use_libheif = true,
                      skia_use_expat = true,
                      skia_use_libjpeg_turbo_decode = true,
                      skia_use_libjpeg_turbo_encode = true,
                      skia_use_libpng_decode = true,
                      skia_use_libpng_encode = true,
                      skia_use_libwebp_decode = true,
                      skia_use_libwebp_encode = true,
                      skia_use_zlib = true}
        for _, component in ipairs(components) do
            args["skia_enable_" .. component] = package:config(component)
        end
        if package:is_arch("x86") then
            args.target_cpu    = "x86"
        elseif package:is_arch("x64") then
            args.target_cpu    = "x64"
        elseif package:is_arch("arm64") then
            args.target_cpu    = "arm64"
        end
        if not package:is_plat("windows") then
            args.cc            = package:build_getenv("cc")
            args.cxx           = package:build_getenv("cxx")
        else
            args.extra_cflags  = {(package:config("vs_runtime"):startswith("MT") and "/MT" or "/MD")}
        end
        if package:is_plat("macosx") then
            args.extra_ldflags = {"-lstdc++"}
            local xcode = import("core.tool.toolchain").load("xcode", {plat = package:plat(), arch = package:arch()})
            args.xcode_sysroot = xcode:config("xcode_sysroot")
        end

        -- fix symbol lookup error: /lib64/libk5crypto.so.3: undefined symbol: EVP_KDF_ctrl, version OPENSSL_1_1_1b
        local LD_LIBRARY_PATH
        if package:is_plat("linux") and linuxos.name() == "fedora" then
            LD_LIBRARY_PATH = os.getenv("LD_LIBRARY_PATH")
            if LD_LIBRARY_PATH then
                local libdir = os.arch() == "x86_64" and "/usr/lib64" or "/usr/lib"
                LD_LIBRARY_PATH = libdir .. ":" .. LD_LIBRARY_PATH
            end
        end

        -- patches
        io.replace("bin/fetch-gn", "import os\n", "import os\nimport ssl\nssl._create_default_https_context = ssl._create_unverified_context\n", {plain = true})
        os.vrunv("python", {"tools/git-sync-deps"}, {
            envs = {
                LD_LIBRARY_PATH = LD_LIBRARY_PATH,
                HTTP_PROXY = os.getenv("HTTP_PROXY"),
                HTTPS_PROXY = os.getenv("HTTPS_PROXY"),
            }})
        local skia_gn = "gn/skia/BUILD.gn"

        if not os.exists(skia_gn) then
            skia_gn = "gn/BUILD.gn"
        end

        io.replace(skia_gn, "libs += [ \"pthread\" ]", "libs += [ \"pthread\", \"m\", \"stdc++\" ]", {plain = true})
        io.replace("gn/toolchain/BUILD.gn", "$shell $win_sdk/bin/SetEnv.cmd /x86 && ", "", {plain = true})
        io.replace("third_party/externals/dng_sdk/source/dng_pthread.cpp", "auto_ptr", "unique_ptr", {plain = true})
        io.replace("BUILD.gn", 'executable%("skia_c_api_example"%) {.-}', "")

        -- set deps flags
        local cflags = {}
        local ldflags = {}
        if package:is_plat("linux") then
            for _, depname in ipairs({"fontconfig", "freetype"}) do
                local fetchinfo = package:dep(depname):fetch()
                if fetchinfo then
                    for _, includedir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                        table.insert(cflags, "-I" .. includedir)
                    end
                    for _, linkdir in ipairs(fetchinfo.linkdirs) do
                        table.insert(ldflags, "-L" .. linkdir)
                    end
                    for _, link in ipairs(fetchinfo.links) do
                        table.insert(ldflags, "-l" .. link)
                    end
                end
            end
        end
        if #cflags > 0 then
            io.replace(skia_gn, "cflags = []", 'cflags = ["' .. table.concat(cflags, '", "') .. '"]', {plain = true})
        end
        if #ldflags > 0 then
            io.replace(skia_gn, "ldflags = []", 'ldflags = ["' .. table.concat(ldflags, '", "') .. '"]', {plain = true})
        end

        -- installation
        import("package.tools.gn").build(package, args, {buildir = "out"})
        os.mv("include", package:installdir())
        os.cd("out")
        os.rm("obj")
        os.rm("*.ninja")
        os.rm("*.ninja*")
        os.rm("*.gn")
        if package:is_plat("windows") then
            os.mv("*.lib", package:installdir("lib"))
            os.trymv("*.dll", package:installdir("bin"))
            os.mv("*.exe", package:installdir("bin"))
        else
            os.mv("*.a", package:installdir("lib"))
            os.trymv("*.so", package:installdir("lib"))
            os.trymv("*.dylib", package:installdir("lib"))
            os.trymv("*", package:installdir("bin"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                SkPaint paint;
                paint.setStyle(SkPaint::kFill_Style);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "core/SkPaint.h"}))
    end)
