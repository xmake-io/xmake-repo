package("freetype")

    set_homepage("https://www.freetype.org")
    set_description("A freely available software library to render fonts.")

    set_urls("https://downloads.sourceforge.net/project/freetype/freetype2/$(version)/freetype-$(version).tar.gz",
             "https://download.savannah.gnu.org/releases/freetype/freetype-$(version).tar.gz",
             "https://gitlab.freedesktop.org/freetype/freetype.git")
    add_versions("2.11.0", "a45c6b403413abd5706f3582f04c8339d26397c4304b78fa552f2215df64101f")
    add_versions("2.10.4", "5eab795ebb23ac77001cfb68b7d4d50b5d6c7469247b0b01b2c953269f658dac")
    add_versions("2.9.1", "ec391504e55498adceb30baceebd147a6e963f636eb617424bcfc47a169898ce")

    add_extsources("apt::libfreetype6", "pkgconfig::freetype2", "brew::freetype")

    add_configs("bzip2", {description = "Support bzip2 compressed fonts", default = false, type = "boolean"})
    add_configs("png", {description = "Support PNG compressed OpenType embedded bitmaps", default = false, type = "boolean"})
    add_configs("woff2", {description = "Use Brotli library to support decompressing WOFF2 fonts", default = false, type = "boolean"})
    add_configs("zlib", {description = "Support reading gzip-compressed font files", default = false, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_deps("cmake")
    else
        add_deps("pkg-config")
    end

    add_includedirs("include/freetype2")

    on_load(function (package)
        local function add_dep(conf, pkg)
            if package:config(conf) then
                package:add("deps", pkg or conf)
            end
        end

        add_dep("bzip2")
        add_dep("png", "libpng")
        add_dep("woff2", "brotli")
        add_dep("zlib")
    end)

    on_install("windows", "mingw", function (package)
        local function add_dep(dep, cmakeConf, cmakeDisableConf)
            if package:config("dep") then
                table.insert(configs, "-DFT_WITH_" .. cmakeConf .. "=ON")
            else
                table.insert(configs, "-DCMAKE_DISABLE_FIND_PACKAGE_" .. (cmakeDisableConf or cmakeConf) .. "=ON")
            end
        end

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        add_dep("bzip2", "BZIP2", "Bzip2")
        add_dep("png", "PNG")
        add_dep("woff2", "BROTLI", "BrotliDec")
        add_dep("zlib", "ZLIB")

        -- brotli isn't found automatically
        if package:config("woff2") then
            local brotli = package:dep("brotli")
            if brotli and not brotli:is_system() then
                local fetchinfo = brotli:fetch()
                table.insert(configs, "-DBROTLIDEC_INCLUDE_DIRS=" .. table.concat(fetchinfo.includedirs or fetchinfo.sysincludedirs, ";"))
                table.insert(configs, "-DBROTLIDEC_LIBRARIES=" .. table.concat(fetchinfo.libfiles, ";"))
            end
        end

        import("package.tools.cmake").install(package, configs)
    end)

    on_install("linux", "macosx", function (package)
        io.gsub("builds/unix/configure", "libbrotlidec", "brotli")
        local configs = { "--enable-freetype-config",
                          "--without-harfbuzz"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))

        local function add_dep(conf, name)
            table.insert(configs, "--with-" .. (name or conf) .. "=" .. (package:config(conf) and "yes" or "no"))
        end

        add_dep("bzip2")
        add_dep("png")
        add_dep("woff2", "brotli")
        add_dep("zlib", "zlib")

        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("FT_Init_FreeType", {includes = {"ft2build.h", "freetype/freetype.h"}}))
    end)
