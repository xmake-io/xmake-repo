package("khrplatform")
    set_kind("library", {headeronly = true})
    set_homepage("https://registry.khronos.org/EGL")
    set_description("Khronos Shared Platform Header (<KHR/khrplatform.h>)")

    add_urls("https://github.com/KhronosGroup/EGL-Registry.git")

    add_versions("2023.12.16", "a03692eea13514d9aef01822b2bc6575fcabfac2")

    on_install(function (package)
        os.vcp("api/KHR", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cincludes("KHR/khrplatform.h"))
    end)
