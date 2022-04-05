package("libcroco")

    set_homepage("https://gitlab.com/inkscape/libcroco")
    set_description("Libcroco is a standalone css2 parsing and manipulation library.")
    set_license("LGPL-2.0")

    add_urls("https://download.gnome.org/sources/libcroco/$(version).tar.xz", {version = function (version)
        return format("%d.%d/libcroco-%s", version:major(), version:minor(), version)
    end})
    add_versions("0.6.13", "767ec234ae7aa684695b3a735548224888132e063f92db585759b422570621d4")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("glib", "libxml2")
    on_load("windows", "macosx", "linux", function (package)
        local ver = package:version()
        package:add("includedirs", format("include/libcroco-%d.%d", ver:major(), ver:minor()))
    end)

    on_install("windows", "macosx", "linux", function (package)
        os.cp(path.join(os.scriptdir(), "port", "xmake.lua"), "xmake.lua")
        io.replace("src/cr-rgb.c", "#include \"config.h\"", "", {plain = true})
        import("package.tools.xmake").install(package, {
            installprefix = package:installdir():gsub("\\", "\\\\"),
            vers = package:version_str()
        })
    end)

    on_test(function (package)
        assert(package:has_cfuncs("cr_utils_is_newline", {includes = "libcroco/libcroco.h"}))
    end)
