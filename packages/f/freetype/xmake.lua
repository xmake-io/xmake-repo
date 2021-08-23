package("freetype")

    set_homepage("https://www.freetype.org")
    set_description("A freely available software library to render fonts.")

    set_urls("https://downloads.sourceforge.net/project/freetype/freetype2/$(version)/freetype-$(version).tar.gz",
             "https://download.savannah.gnu.org/releases/freetype/freetype-$(version).tar.gz",
             "https://gitlab.freedesktop.org/freetype/freetype.git")
    add_versions("2.9.1", "ec391504e55498adceb30baceebd147a6e963f636eb617424bcfc47a169898ce")
    add_versions("2.10.4", "5eab795ebb23ac77001cfb68b7d4d50b5d6c7469247b0b01b2c953269f658dac")

    local configdeps = {woff2 = "brotli",
                        bzip2 = "bzip2",
                        png   = "libpng",
                        zlib  = "zlib"}

    add_includedirs("include/freetype2")
    if is_plat("windows", "mingw") then
        add_deps("cmake")
    else
        add_deps("pkg-config")
        for conf, dep in pairs(configdeps) do
            add_configs(conf, {description = "Enable " .. conf .. " support.", default = false, type = "boolean"})
        end
    end

    if on_fetch then
        on_fetch("linux", "macosx", function (package, opt)
            if opt.system then
                return find_package("pkgconfig::freetype2")
            end
        end)
    end

    on_load("linux", "macosx", function (package)
        for conf, dep in pairs(configdeps) do
            if package:config(conf) then
                package:add("deps", dep)
            end
        end
    end)

    on_install("windows", "mingw", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
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
