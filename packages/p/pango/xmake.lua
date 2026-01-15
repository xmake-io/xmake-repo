package("pango")
    set_homepage("https://www.pango.org/")
    set_description("Framework for layout and rendering of i18n text")
    set_license("LGPL-2.0")

    add_urls("https://gitlab.gnome.org/GNOME/pango/-/archive/$(version)/pango-$(version).tar.gz",
             "https://gitlab.gnome.org/GNOME/pango.git")

    add_versions("1.51.1", "ea92cd570cdba62ca52cc0a7c9ea3cd311b6da3f0328a5aa8a4a81b0a74944a5")
    add_versions("1.50.3", "4a8b0cf33d5f9ecaa9cd99dd72703d5c4c53bc58df64dd9538493bb4356ab691")

    add_configs("fontconfig", {description = "Build with FontConfig support", default = true, type = "boolean"})
    add_configs("cairo", {description = "Build with cairo support", default = true, type = "boolean"})
    add_configs("freetype", {description = "Build with freetype support", default = true, type = "boolean"})
    if is_plat("linux") then
        add_configs("libthai", {description = "Build with libthai support", default = true, type = "boolean"})
    end

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::pango")
    elseif is_plat("linux") then
        add_extsources("apt::libpango-1.0-0", "pacman::pango")
    elseif is_plat("macosx") then
        add_extsources("brew::pango")
    end

    add_deps("meson", "ninja")
    add_deps("fribidi", "glib")
    add_deps("harfbuzz", {configs = {glib = true}})

    add_includedirs("include", "include/pango-1.0")

    on_load(function (package)
        for _, name in ipairs({"fontconfig", "cairo", "freetype", "libthai"}) do
            if package:config(name) then
                package:add("deps", name)
            end
        end
        if package:config("fontconfig") then
            if package:is_plat("windows", "mingw", "msys", "cygwin") then
                -- fontconfig symbols are absorbed into pango.dll and re-exported by Meson.
                -- Linking both pango and fontconfig downstream will cause symbol duplication.
                package:add("deps", "fontconfig", {configs = {shared = package:config("shared")}})
            else
                package:add("deps", "fontconfig")
            end
        end
    end)

    on_install("windows|!arm*", "macosx", "linux", "cross", "mingw", function (package)
        import("package.tools.meson")

        io.gsub("meson.build", "subdir%('tests'%)", "")
        io.gsub("meson.build", "subdir%('fuzzing'%)", "")
        io.gsub("meson.build", "subdir%('docs'%)", "")
        io.gsub("meson.build", "subdir%('examples'%)", "")
        io.gsub("meson.build", "subdir%('utils'%)", "")
        io.gsub("meson.build", "subdir%('tools'%)", "")

        io.replace("meson.build", "[ 'CoreFoundation', 'ApplicationServices' ]", "[ 'CoreFoundation', 'ApplicationServices', 'Foundation' ]", {plain = true})
        io.replace("meson.build", "dependency('gi-docgen'", "dependency(''", {plain = true})
        io.replace("meson.build", "fallback: ['gi-docgen', 'dummy_dep']", "fallback: ['dummy_dep']", {plain = true})

        -- fix unexpected -Werror=unused-but-set-variable errors, see https://gitlab.gnome.org/GNOME/pango/-/issues/693
        io.replace("meson.build", "'-Werror=unused-but-set-variable',", "", {plain = true})
        -- fix unexpected -Werror=array-bounds errors, see https://gitlab.gnome.org/GNOME/pango/-/issues/740
        io.replace("meson.build", "'-Werror=array-bounds',", "", {plain = true})

        if not package:is_plat("linux") and package:dep("libintl") and package:dep("libintl"):is_system() then
            io.replace("meson.build", "subdir('pango')", "pango_deps += cc.find_library('intl')\nsubdir('pango')", {plain = true})
        end

        local configs = {"-Dintrospection=disabled", "-Dgtk_doc=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        for _, name in ipairs({"fontconfig", "cairo", "freetype", "libthai"}) do
            table.insert(configs, "-D" .. name .. "=" .. (package:config(name) and "enabled" or "disabled"))
        end

        local envs = meson.buildenvs(package)
        if envs.LDFLAGS then
            -- workaround for https://github.com/xmake-io/xmake/issues/4412
            envs.LDFLAGS = string.gsub(envs.LDFLAGS, "%-libpath:", "/libpath:")
        end

        local cxflags
        if package:is_plat("windows", "mingw") and not package:dep("cairo"):config("shared") then
            cxflags = "-DCAIRO_WIN32_STATIC_BUILD=1"
        end
        meson.install(package, configs, {envs = envs, cxflags = cxflags})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pango_layout_set_text", {includes = "pango/pangocairo.h"}))
    end)
