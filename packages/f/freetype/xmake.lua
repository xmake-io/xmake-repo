package("freetype")

    set_homepage("https://www.freetype.org")
    set_description("A freely available software library to render fonts.")

    if is_plat("windows") then
        set_urls("https://github.com/ubawurinna/freetype-windows-binaries/archive/v$(version).tar.gz")
        add_versions("2.9.1", "60f788b63f1243a30e01611694ed196ee5ad1b89d553527700e5359d57d33b82")
        add_versions("2.10.4", "24d7d3ab605e9f9b338adf0c4200ab14f6601a8c41a98741b9d1ecb3e759869c")
    else
        set_urls("https://downloads.sourceforge.net/project/freetype/freetype2/$(version)/freetype-$(version).tar.gz",
                 "https://download.savannah.gnu.org/releases/freetype/freetype-$(version).tar.gz")
        add_versions("2.9.1", "ec391504e55498adceb30baceebd147a6e963f636eb617424bcfc47a169898ce")
        add_versions("2.10.4", "5eab795ebb23ac77001cfb68b7d4d50b5d6c7469247b0b01b2c953269f658dac")
    end

    local configdeps = {woff2 = "brotli",
                        bzip2 = "bzip2",
                        png   = "libpng",
                        zlib  = "zlib"}

    if not is_plat("windows") then
        for conf, dep in pairs(configdeps) do
            add_configs(conf, {description = "Enable " .. conf .. " support.", default = true, type = "boolean"})
        end
        add_includedirs("include/freetype2")
    end

    if on_fetch then
        on_fetch("linux", "macosx", function (package, opt)
            if opt.system then
                return find_package("pkgconfig::freetype2")
            end
        end)
    end

    on_load("linux", "macosx", function (package)
        package:add("deps", "pkg-config")
        for conf, dep in pairs(configdeps) do
            if package:config(conf) then
                package:add("deps", dep)
            end
        end
    end)

    on_install("windows", function (package)
        os.cp("include", package:installdir())
        os.cp(is_arch("x64") and "win64/*.lib" or "win32/*.lib", package:installdir("lib"))
        os.cp(is_arch("x64") and "win64/*.dll" or "win32/*.dll", package:installdir("bin"))
    end)

    on_install("linux", "macosx", function (package)
        io.gsub("builds/unix/configure", "libbrotlidec", "brotli")
        local configs = { "--enable-freetype-config",
                          "--without-harfbuzz"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        for conf, dep in pairs(configdeps) do
            table.insert(configs, "--with-" .. conf .. "=" .. (package:config(conf) and "yes" or "no"))
        end
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("FT_Init_FreeType", {includes = {"ft2build.h", "freetype/freetype.h"}}))
    end)
