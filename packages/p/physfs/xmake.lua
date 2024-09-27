package("physfs")
    set_homepage("https://icculus.org/physfs/")
    set_description("A portable, flexible file i/o abstraction")
    set_license("zlib")

    set_urls("https://github.com/icculus/physfs/archive/refs/tags/release-$(version).tar.gz",
             "https://github.com/icculus/physfs.git")

    add_versions("3.2.0", "1991500eaeb8d5325e3a8361847ff3bf8e03ec89252b7915e1f25b3f8ab5d560")

    local archivers = {
        ["zip"] = "ZIP",
        ["7z"] = "7zip",
        ["grp"] = "Build Engine GRP",
        ["wad"] = "Doom WAD",
        ["hog"] = "Descent I/II HOG",
        ["mvl"] = "Descent I/II MVL",
        ["qpak"] = "Quake I/II QPAK support",
        ["slb"] = "I-War / Independence War SLB",
        ["iso9660"] = "ISO9660",
        ["vdf"] = "Gothic I/II VDF archive"
    }
    for k, v in pairs(archivers) do
        add_configs(k, {description = "Enable " .. v .. " support", default = true, type = "boolean"})
    end

    add_deps("cmake")
    if is_plat("windows") then
        add_syslinks("User32", "Advapi32", "Shell32")
    end

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DPHYSFS_BUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DPHYSFS_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        for k, v in pairs(archivers) do
            table.insert(configs, "-DPHYSFS_ARCHIVE_" .. v:upper() .. "=" .. (package:config(k) and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("PHYSFS_init", {includes = "physfs.h"}))
    end)
