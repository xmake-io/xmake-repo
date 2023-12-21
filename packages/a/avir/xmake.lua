package("avir")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/avaneev/avir")
    set_description("High-quality pro image resizing / scaling C++ library, including a very fast Lanczos resizer")
    set_license("MIT")

    add_urls("https://github.com/avaneev/avir/archive/refs/tags/$(version).tar.gz",
             "https://github.com/avaneev/avir.git")

    add_versions("3.0", "011909d31cf782152a69f570563eb70700504f168174a6049b6acbb9b9f511ea")

    on_install(function (package)
        os.cp("*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("avir.h"))
    end)
