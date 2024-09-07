package("wixtoolset")
    set_kind("binary")
    set_homepage("https://wixtoolset.org/")
    set_description("The most powerful set of tools available to create your Windows installation experience.")

    set_urls("https://www.nuget.org/api/v2/package/wix/$(version)/#wix-$(version).zip")

    add_versions("5.0.0", "e8243606c71fa5bc2e0eb14d6005f42f1282b61540fb224b0004de563a81f74d")
    add_resources("5.0.0", "ui", "https://www.nuget.org/api/v2/package/WixToolset.UI.wixext/5.0.0/#ui-5.0.0.zip", "fd0ccff8bf56eeb5fe306f3ad09eb74ba9546186f51d9d065f75dfc28310aa9d")

    on_load(function (package)
        package:addenv("WIX_EXTENSIONS", "bin")
        package:mark_as_pathenv("WIX_EXTENSIONS")
    end)

    on_install("windows", function (package)
        import("lib.detect.find_file")
        import("lib.detect.find_directory")
        local wix_folder = path.directory(find_file("wix.exe", "tools/**"))
        os.cp(path.join(wix_folder, "/**"), package:installdir("bin"))

        local version = package:version():rawstr()
        local ui_folder = path.join(package:installdir("bin"), ".wix", "extensions", "WixToolset.UI.wixext", version)
        os.cp(path.join(package:resourcedir("ui")), ui_folder)
    end)

    on_test(function(package)
        os.vrunv("wix", {"--version"})
    end)
