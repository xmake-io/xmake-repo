package("appimage")

    set_kind("binary")
    set_homepage("https://appimage.org/")
    set_description("AppImage packaging tool (appimagetool) for creating AppImage files")
    set_license("MIT")

    if is_host("linux") then
        local arch
        if os.arch() == "x86_64" then
            arch = "x86_64"
        elseif os.arch():find("arm64.*") then
            arch = "aarch64"
        elseif os.arch() == "i386" then
            arch = "i686"
        end

        if arch then
            add_urls("https://github.com/AppImage/AppImageKit/releases/download/$(version)", {version = function (version)
                    local ver = version:gsub("%.0$", "")
                    local prefix = (ver == "13" and "obsolete-" or "")
                    return ver .. "/" .. prefix .. "appimagetool-" .. arch .. ".AppImage"
                end})

            if arch == "x86_64" then
                add_versions("13.0", "df3baf5ca5facbecfc2f3fa6713c29ab9cefa8fd8c1eac5d283b79cab33e4acb")
                add_versions("12.0", "d918b4df547b388ef253f3c9e7f6529ca81a885395c31f619d9aaf7030499a13")
            elseif arch == "aarch64" then
                add_versions("13.0", "334e77beb67fc1e71856c29d5f3f324ca77b0fde7a840fdd14bd3b88c25c341f")
                add_versions("12.0", "c9d058310a4e04b9fbbd81340fff2b5fb44943a630b31881e321719f271bd41a")
            elseif arch == "i686" then
                add_versions("13.0", "104978205c888cb2ad42d1799e03d4621cb9a6027cfb375d069b394a82ff15d1")
                add_versions("12.0", "3af6839ab6d236cd62ace9fbc2f86487f0bf104f521d82da6dea4dab8d3ce4ca")
            end
        end
    end

    add_configs("extract_and_run", {description = "Enable APPIMAGE_EXTRACT_AND_RUN environment variable.", default = true, type = "boolean"})

    on_load(function (package)
        if package:config("extract_and_run") then
            package:addenv("APPIMAGE_EXTRACT_AND_RUN", "1")
        end
    end)

    on_install("@linux", function (package)
        local appimage_file = package:originfile()
        os.mv(appimage_file, "appimagetool")
        os.vrunv("chmod", {"+x", "appimagetool"})
        os.cp("appimagetool", package:installdir("bin"))
    end)

    on_test(function (package)
        os.vrun("appimagetool --version")
    end)

