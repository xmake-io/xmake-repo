package("dotnet-cppcli")
    set_kind("addon")
    set_homepage("https://github.com/microdee/xmake.dotnet-cppcli")
    set_description("A simple addon for compiling C++/CLI targeting CoreCLR or in English .NET 5+.")
    set_license("MIT")

    add_urls(
        "https://github.com/microdee/xmake.dotnet-cppcli/archive/refs/tags/$(version).tar.gz",
        "https://github.com/microdee/xmake.dotnet-cppcli.git"
    )
    add_versions("v1.0.2", "253f59d7a3af49cb519edba06a9267f0230348340e9687cfb3c58cac07732d49")
    
    add_deps("rats-utils", {kind = "addon"})

    on_test(function (package)
        assert(package:has_addon({
            rules   = "cppcli",
            modules = "cppcli"
        }))
    end)
