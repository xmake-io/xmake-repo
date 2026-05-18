package("stv")
    set_kind("library", { headeronly = true })
    set_description("A Lightweight C String-View Library")
    set_homepage("https://github.com/AkarinATCP/stv")
    set_license("MIT")

    set_urls(
        "https://github.com/AkarinATCP/stv/archive/refs/tags/$(version).tar.gz",
        "https://github.com/AkarinATCP/stv.git"
    )

    add_versions("v1.0.0", "da8e30e58a57580f79ae9983eb53306d47df20c88509b118bc54e2fc54c73b09")

    on_install(function(package)
        os.cp("include/stv.h", package:installdir("include"))
    end)

    on_test(function(package)
        assert(package:has_cincludes("stv.h"), "stv.h not found")
    end)


    