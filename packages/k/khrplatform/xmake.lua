package("khrplatform")
    set_kind("library", {headeronly = true})
    set_homepage("https://registry.khronos.org/EGL")
    set_description("Khronos Shared Platform Header (<KHR/khrplatform.h>)")

    add_urls("https://registry.khronos.org/EGL/api/KHR/khrplatform.h")

    add_versions("latest", "7b1e01aaa7ad8f6fc34b5c7bdf79ebf5189bb09e2c4d2e79fc5d350623d11e83")

    on_install(function (package)
        os.mkdir(package:installdir("include") .. "/KHR")
        os.cp("../khrplatform.h", package:installdir("include") .. "/KHR")
    end)

    on_test(function (package)
        assert(package:has_cincludes("KHR/khrplatform.h"))
    end)
