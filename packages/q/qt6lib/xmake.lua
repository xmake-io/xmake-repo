package("qt6lib")
    set_kind("template")
    set_homepage("https://www.qt.io")
    set_description("Qt is the faster, smarter way to create innovative devices, modern UIs & applications for multiple screens. Cross-platform software development at its best.")
    set_license("LGPL-3")

    add_configs("shared", {description = "Download shared binaries.", default = true, type = "boolean", readonly = true})
    add_configs("vs_runtime", {description = "Set vs compiler runtime.", default = "MD", readonly = true})

    -- Sync with qt6base and qt-tools
    add_versions("6.3.0", "dummy")
    add_versions("6.3.1", "dummy")
    add_versions("6.3.2", "dummy")
    add_versions("6.4.0", "dummy")
    add_versions("6.4.1", "dummy")
    add_versions("6.4.2", "dummy")
    add_versions("6.4.3", "dummy")
    add_versions("6.5.0", "dummy")
    add_versions("6.5.1", "dummy")
    add_versions("6.5.2", "dummy")
    add_versions("6.5.3", "dummy")
    add_versions("6.6.0", "dummy")
    add_versions("6.6.1", "dummy")
    add_versions("6.6.2", "dummy")
    add_versions("6.6.3", "dummy")
    add_versions("6.7.0", "dummy")
    add_versions("6.7.1", "dummy")
    add_versions("6.7.2", "dummy")
    add_versions("6.8.0", "dummy")
    add_versions("6.8.1", "dummy")
    add_versions("6.8.2", "dummy")
    add_versions("6.8.3", "dummy")
    add_versions("6.9.0", "dummy")
    add_versions("6.9.1", "dummy")

    on_load(function (package)
        package:add("deps", "qt6base", {debug = package:is_debug(), version = package:version_str()})
    end)

    on_fetch(function (package)
        local qt = package:dep("qt6base"):fetch()
        if not qt then
            return
        end
        -- Ensure all direct dependencies are fetched
        for _, dep in ipairs(package:plaindeps()) do
            if not dep:fetch() and dep:parents(package:name()) then
                return
            end
        end

        local libname = assert(package:data("libname"), "this package must not be used directly")

        local links = table.wrap(package:data("links"))
        local includedirs = {qt.includedir}
        local linkname
        local frameworks
        if package:is_plat("windows") then
            linkname = "Qt6" .. libname
            if package:is_debug() then
                linkname = linkname .. "d"
            end
            table.insert(includedirs, path.join(qt.includedir, "Qt" .. libname))
        elseif package:is_plat("android") then
            linkname = "Qt6" .. libname
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
            table.insert(includedirs, path.join(qt.libdir, "Qt" .. libname .. ".framework", "Headers"))
            frameworks = "Qt" .. libname
        else
            linkname = "Qt6" .. libname
            table.insert(includedirs, path.join(qt.includedir, "Qt" .. libname))
        end

        table.insert(links, 1, linkname)
        if frameworks then
            table.join2(frameworks, package:data("frameworks"))
        else
            frameworks = package:data("frameworks")
        end

        return {
            qtdir = qt,
            version = qt.version,
            includedirs = includedirs,
            links = links,
            linkdirs = qt.libdir,
            frameworks = frameworks,
            frameworkdirs = qt.libdir,
            syslinks = package:data("syslinks")
        }
    end)

    on_install("windows|x64,linux|x86_64,linux|arm64,macosx,mingw|x86_64@windows,linux,macosx", function (package)
        local qt = package:dep("qt6base"):data("qt")
        assert(qt, "qt6base is required")
    end)

    on_install("android|arm64-v8a,armeabi-v7a,armeabi,x86_64,x86@windows,linux,macosx", function (package)
        local qt = package:dep("qt6base"):data("qt")
        assert(qt, "qt6base is required")
    end)

    on_install("iphoneos,wasm@windows,linux,macosx", function (package)
        local qt = package:dep("qt6base"):data("qt")
        assert(qt, "qt6base is required")
    end)
