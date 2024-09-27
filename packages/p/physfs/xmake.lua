package("physfs")
    set_homepage("https://icculus.org/physfs/")
    set_description("A portable, flexible file i/o abstraction")
    set_license("zlib")

    set_urls("https://github.com/icculus/physfs.git")

    add_versions("2024.09.23", "74c30545031ca8cdb69b2f1ec173e77d79078093")

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

    if is_plat("windows") then
        add_syslinks("user32", "advapi32", "shell32")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    elseif is_plat("macosx") then
        add_frameworks("IOKit", "Foundation")
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DPHYSFS_BUILD_TEST=OFF", "-DPHYSFS_BUILD_DOCS=OFF"}
        table.insert(configs, "-DPHYSFS_BUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DPHYSFS_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        for k, v in pairs(archivers) do
            table.insert(configs, "-DPHYSFS_ARCHIVE_" .. v:upper() .. "=" .. (package:config(k) and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.trycp(path.join(package:buildir(), "physfs.pdb"), dir)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("PHYSFS_init", {includes = "physfs.h"}))
    end)
