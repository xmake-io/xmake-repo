package("qt5lib")
    set_homepage("https://www.qt.io")
    set_description("Qt is the faster, smarter way to create innovative devices, modern UIs & applications for multiple screens. Cross-platform software development at its best.")
    set_license("LGPL-3")

    add_configs("shared", {description = "Download shared binaries.", default = true, type = "boolean", readonly = true})
    add_configs("vs_runtime", {description = "Set vs compiler runtime.", default = "MD", readonly = true})

    add_versions("5.15.2", "dummy")
    add_versions("5.12.5", "dummy")

    on_load(function (package)
        if package.is_template then
            package:set("kind", "template")
        end
        package:add("deps", "qt5base", {debug = package:is_debug(), version = package:version_str()})
    end)

    on_fetch(function (package)
        local qt = package:dep("qt5base"):data("qt")
        if not qt then
            return
        end

        local libname = assert(package:data("libname"), "this package must not be used directly")

        local links = table.wrap(package:data("links"))
        local includedirs = {qt.includedir}
        local linkname
        if package:is_plat("windows") then
            linkname = "Qt5" .. libname
            if package:is_debug() then
                linkname = linkname .. "d"
            end
            table.insert(includedirs, path.join(qt.includedir, "Qt" .. libname))
        elseif package:is_plat("android") then
            linkname = "Qt5" .. libname
            if package:is_arch("x86_64", "x64") then
                linkname = linkname .. "_x86_64"
            elseif package:is_arch("arm64", "arm64-v8a") then
                linkname = linkname .. "_arm64-v8a"
            elseif package:is_arch("armv7", "armeabi-v7a", "armeabi", "armv7-a", "armv5te") then
                linkname = linkname .. "_armeabi-v7a"
            elseif package:is_arch("x86") then
                linkname = linkname .. "_x86"
            end
            table.insert(includedirs, path.join(qt.includedir, "Qt" .. libname))
        elseif package:is_plat("macosx") then
            table.insert(includedirs, path.join(qt.libdir, "Qt" .. libname .. ".framework", "Versions", "5", "Headers"))
            frameworks = "Qt" .. libname
        else
            linkname = "Qt5" .. libname
            table.insert(includedirs, path.join(qt.includedir, "Qt" .. libname))
        end

        table.insert(links, 1, linkname)

        return {
            qtdir = qt,
            version = qt.version,
            includedirs = includedirs,
            links = links,
            linkdirs = qt.libdir,
            frameworks = package:data("frameworks"),
            frameworkdirs = qt.libdir,
            syslinks = package:data("syslinks")
        }
    end)

    on_install("windows", "linux", "macosx", "mingw", "android", "iphoneos", function (package)
        local qt = package:dep("qt5base"):data("qt")
        assert(qt, "qt5base is required")
    end)
