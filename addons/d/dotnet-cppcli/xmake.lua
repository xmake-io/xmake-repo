package("dotnet-cppcli")
    set_kind("addon")
    set_homepage("https://github.com/microdee/xmake.dotnet-cppcli")
    set_description("A simple addon for compiling C++/CLI targeting CoreCLR or in English .NET 5+.")
    set_license("MIT")

    add_urls(
        "https://github.com/microdee/xmake.dotnet-cppcli/archive/refs/tags/$(version).tar.gz",
        "https://github.com/microdee/xmake.dotnet-cppcli.git"
    )
    add_versions("v1.0.1", "7a7a616fa2e7cece3fe30c759cdd9f00e25965560abf2c452493639d8650efa8")
    
    add_deps("rats-utils", {kind = "addon"})

    on_test(function (package)
        assert(package:has_addon({
            rules   = "cppcli",
            modules = "cppcli"
        }))
    end)
