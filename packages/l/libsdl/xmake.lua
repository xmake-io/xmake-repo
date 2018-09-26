package("libsdl")

    set_homepage("https://www.libsdl.org/")
    set_description("Simple DirectMedia Layer")

    if is_plat("windows") then
        set_urls("https://www.libsdl.org/release/SDL2-devel-$(version)-VC.zip")
        add_versions("2.0.8", "68505e1f7c16d8538e116405411205355a029dcf2df738dbbc768b2fe95d20fd")
    else
        set_urls("https://www.libsdl.org/release/SDL2-$(version).zip")
        add_versions("2.0.8", "e6a7c71154c3001e318ba7ed4b98582de72ff970aca05abc9f45f7cbdc9088cb")
    end

    on_build("windows", function (package)
    end)

    on_install("windows", function (package)
        os.cp("include", package:installdir())
        os.cp("lib/$(arch)/*.lib", package:installdir("lib"))
        os.cp("lib/$(arch)/*.dll", package:installdir("lib"))
    end)

    on_build("macosx", "linux", function (package)
        import("package.builder.autoconf").build(package)
    end)

    on_install("macosx", "linux", function (package)
        import("package.builder.autoconf").install(package)
    end)
