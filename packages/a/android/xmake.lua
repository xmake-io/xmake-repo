package("android")
    set_homepage("https://android.googlesource.com/platform/frameworks/base")
    set_description("")

    add_urls("https://android.googlesource.com/platform/manifest.git")

    add_versions("2024.10.01", "7f9b5893c3d20455fd57b7b56527cd9a63311cab")

    add_deps("repo")

    -- Generate config based on xml projects in manifest
    on_load(function (package)
    
    end)

    on_install(function (package)
        os.vrun("repo init --partial-clone -b main -u https://android.googlesource.com/platform/manifest")
        os.vrun("repo sync -j8")
    end)

    on_test(function (package)
    end)
