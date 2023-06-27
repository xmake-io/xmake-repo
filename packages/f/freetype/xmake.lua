package("freetype")

    set_homepage("https://www.freetype.org")
    set_description("A freely available software library to render fonts.")

    set_urls("https://downloads.sourceforge.net/project/freetype/freetype2/$(version)/freetype-$(version).tar.gz",
             "https://download.savannah.gnu.org/releases/freetype/freetype-$(version).tar.gz",
             "https://gitlab.freedesktop.org/freetype/freetype.git")
    add_versions("2.13.0", "a7aca0e532a276ea8d85bd31149f0a74c33d19c8d287116ef8f5f8357b4f1f80")
    add_versions("2.12.1", "efe71fd4b8246f1b0b1b9bfca13cfff1c9ad85930340c27df469733bbb620938")
    add_versions("2.11.1", "f8db94d307e9c54961b39a1cc799a67d46681480696ed72ecf78d4473770f09b")
    add_versions("2.11.0", "a45c6b403413abd5706f3582f04c8339d26397c4304b78fa552f2215df64101f")
    add_versions("2.10.4", "5eab795ebb23ac77001cfb68b7d4d50b5d6c7469247b0b01b2c953269f658dac")
    add_versions("2.9.1", "ec391504e55498adceb30baceebd147a6e963f636eb617424bcfc47a169898ce")

    add_patches("2.11.0", path.join(os.scriptdir(), "patches", "2.11.0", "writing_system.patch"), "3172cf1e50501fc7455d9bb04ef4d5bb35b9712bb635f217f90ae6b2f7532eef")

    if not is_host("windows") then
        add_extsources("pkgconfig::freetype2")
    end

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::freetype")
    elseif is_plat("linux") then
        add_extsources("pacman::freetype2", "apt::libfreetype-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::freetype")
    end

    add_configs("bzip2", {description = "Support bzip2 compressed fonts", default = false, type = "boolean"})
    add_configs("png", {description = "Support PNG compressed OpenType embedded bitmaps", default = false, type = "boolean"})
    add_configs("woff2", {description = "Use Brotli library to support decompressing WOFF2 fonts", default = false, type = "boolean"})
    add_configs("zlib", {description = "Support reading gzip-compressed font files", default = true, type = "boolean"})
    add_configs("harfbuzz", {description = "Support harfbuzz", default = false, type = "boolean"})

    add_deps("cmake")
    if is_plat("windows", "mingw") and is_subhost("windows") then
        add_deps("pkgconf")
    elseif is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_includedirs("include/freetype2")

    on_load(function (package)
        local function add_dep(conf, pkg)
            if package:config(conf) then
                package:add("deps", pkg or conf)
            end
        end

        add_dep("bzip2")
        add_dep("zlib")
        add_dep("png", "libpng")
        add_dep("woff2", "brotli")
        add_dep("harfbuzz")
    end)

    on_install(function (package)
        local configs = {"-DCMAKE_INSTALL_LIBDIR=lib"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        local function add_dep(opt)
            if package:config(opt.conf) then
                table.insert(configs, "-DFT_WITH_" .. opt.cmakewith .. "=ON")

                local lib = package:dep(opt.pkg or opt.conf)
                if lib and not lib:is_system() then
                    local includeconf = opt.cmakeinclude or (opt.cmakewith .. "_INCLUDE_DIRS")
                    local libconf = opt.cmakelib or (opt.cmakewith .. "_LIBRARIES")
                    local fetchinfo = lib:fetch()
                    if fetchinfo then
                        table.insert(configs, "-D" .. includeconf .. "=" .. table.concat(fetchinfo.includedirs or fetchinfo.sysincludedirs, ";"))
                        table.insert(configs, "-D" .. libconf .. "=" .. table.concat(fetchinfo.libfiles, ";"))
                    end
                end
            else
                table.insert(configs, "-DCMAKE_DISABLE_FIND_PACKAGE_" .. (opt.cmakedisable or opt.cmakewith) .. "=ON")
            end
        end
        add_dep({conf = "bzip2", cmakewith = "BZIP2", cmakedisable = "BZip2", cmakeinclude = "BZIP2_INCLUDE_DIR"})
        add_dep({conf = "png", pkg = "libpng", cmakewith = "PNG", cmakeinclude = "PNG_PNG_INCLUDE_DIR", cmakelib = "PNG_LIBRARY"})
        add_dep({conf = "woff2", pkg = "brotli", cmakewith = "BROTLI", cmakedisable = "BrotliDec", cmakeinclude = "BROTLIDEC_INCLUDE_DIRS", cmakelib = "BROTLIDEC_LIBRARIES"})
        add_dep({conf = "zlib", cmakewith = "ZLIB", cmakeinclude = "ZLIB_INCLUDE_DIR", cmakelib = "ZLIB_LIBRARY"})
        add_dep({conf = "harfbuzz", pkg = "harfbuzz", cmakewith = "HARFBUZZ", cmakedisable = "HarfBuzz", cmakeinclude = "HarfBuzz_INCLUDE_DIR", cmakelib = "HarfBuzz_LIBRARY"})

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("FT_Init_FreeType", {includes = {"ft2build.h", "freetype/freetype.h"}}))
    end)
