package("rgfw")
    set_homepage("https://github.com/ColleagueRiley/RGFW")
    set_description("A single-header windowing framework for creating windows, graphics contexts and handling input.")
    set_license("zlib")

    add_urls("https://github.com/ColleagueRiley/RGFW/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ColleagueRiley/RGFW.git")

    add_versions("1.8.1", "39f9dc8f89e86926fe2be4ffd6cdc877c1e7d179e24e3c803389ece50d6aef60")

    add_configs("headeronly", { description = "Use RGFW as a single-header library.", default = true, type = "boolean" })
    add_configs("x11", { description = "Build support for X11.", default = is_plat("linux", "bsd"), type = "boolean" })
    add_configs("wayland", { description = "Build support for Wayland.", default = false, type = "boolean" })

    add_deps("opengl", { optional = true })

    if is_plat("windows", "mingw", "msys") then
        add_syslinks("gdi32", "shell32", "user32")
    elseif is_plat("macosx") then
        add_frameworks("Cocoa", "CoreVideo", "IOKit")
    elseif is_plat("linux", "bsd") then
        add_syslinks("dl", "pthread")
    end

    on_check("linux", "bsd", function (package)
        if not package:config("x11") and not package:config("wayland") then
            raise("package(rgfw): requires at least one backend, x11 or wayland")
        end
    end)

    on_load( function (package)
        if package:config("headeronly") then
            package:set("kind", "library", { headeronly = true })
        end
        if package:config("x11") then
            package:add("defines", "RGFW_X11")
            package:add("deps", "libx11", "libxrandr", "libxcursor", "libxi", "libxext")
        end
        if package:config("wayland") then
            package:add("defines", "RGFW_WAYLAND")
            package:add("deps", "wayland", "wayland-protocols", "libxkbcommon")
        end
        if not package:config("headeronly") and ( not package:is_plat("windows", "mingw", "msys") or package:config("shared")) then
            package:add("defines", "RGFW_IMPORT")
        end
    end)

    on_install("windows", "mingw", "msys", "linux", "bsd", "macosx", "wasm", function (package)
        os.cp("RGFW.h", package:installdir("include"))
        os.cp("XDL.h", package:installdir("include"))
        if not package:config("headeronly") then
            local makeargs = { }
            if package:config("wayland") then
                table.insert(makeargs, package:config("x11") and "WAYLAND_X11=1" or "WAYLAND_ONLY=1")
                local wayland_protocols = package:dep("wayland-protocols")
                if wayland_protocols then
                    local protocols_dir = wayland_protocols:installdir("share", "wayland-protocols")
                    if protocols_dir then
                        io.replace("Makefile", "/usr/share/wayland-protocols", protocols_dir, { plain = true })
                    end
                end
            end

            local cflags = { }
            for _, dep in ipairs(package:librarydeps()) do
                local fetchinfo = dep:fetch()
                if fetchinfo then
                    for _, includedir in ipairs(table.join(fetchinfo.includedirs or { }, fetchinfo.sysincludedirs or { })) do
                        table.insert(cflags, "-I" .. includedir)
                    end
                    for _, linkdir in ipairs(fetchinfo.linkdirs or { }) do
                        table.insert(cflags, "-L" .. linkdir)
                    end
                end
            end
            if #cflags > 0 then
                table.insert(makeargs, "CUSTOM_CFLAGS=" .. table.concat(cflags, " "))
            end

            local target = "libRGFW.a"
            if package:config("shared") then
                if package:is_plat("windows", "mingw", "msys") then
                    target = "libRGFW.dll"
                elseif package:is_plat("macosx") then
                    target = "libRGFW.dylib"
                else
                    target = "libRGFW.so"
                end
            end
            table.insert(makeargs, target)
            import("package.tools.make").build(package, makeargs)
            if package:config("shared") and package:is_plat("windows", "mingw", "msys") then
                os.cp("*.dll", package:installdir("bin"))
                os.trycp("*.dll.a", package:installdir("lib"))
                os.trycp("*.lib", package:installdir("lib"))
            else
                os.cp(target, package:installdir("lib"))
            end
        end
    end)

    on_test(function (package)
        local configs = { languages = package:is_plat("wasm") and "gnu99" or "c99" }
        if package:config("headeronly") then
            configs.defines = "RGFW_IMPLEMENTATION"
        end
        assert(package:check_csnippets({ test = [[
            #include <RGFW.h>
            void test(void) {
                RGFW_sizeofInfo();
            }
        ]] }, { configs = configs }))
    end)
