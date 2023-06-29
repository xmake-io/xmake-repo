package("x265")

    set_homepage("http://x265.org")
    set_description("A free software library and application for encoding video streams into the H.265/MPEG-H HEVC compression format.")

    add_urls("https://github.com/videolan/x265/archive/$(version).tar.gz",
             "https://github.com/videolan/x265.git",
             "https://bitbucket.org/multicoreware/x265_git")

    add_versions("3.2", "4dd707648ea90b96bf1f8ea6a36ed21c11fe3a9048923909c5b629755ca8d8f3")
    add_versions("3.2.1", "b5ee7ea796a664d6e2763f9c0ae281fac5d25892fc2cb134698547103466a06a")
    add_versions("3.3", "ca25a38772fc6b49e5f1aa88733bc1dc92da7dc18f02a85cc3e99d76ba85b0a9")
    add_versions("3.4", "544d147bf146f8994a7bf8521ed878c93067ea1c7c6e93ab602389be3117eaaf")
    add_deps("cmake", "nasm")

    if is_plat("macosx") then
        add_syslinks("c++")
    elseif is_plat("linux") then
        add_syslinks("pthread", "dl")
    end

    on_install("linux", "macosx", function (package)
        os.cd("build/linux")
        os.vrun("./multilib.sh")
        os.cp("8bit/libx265.a", package:installdir("lib"))
        os.cp("8bit/x265_config.h", package:installdir("include"))
        os.cp("../../source/x265.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("x265_api_get", {includes = "x265.h"}))
    end)
