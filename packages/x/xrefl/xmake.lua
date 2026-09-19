package("xrefl")
    set_kind("binary")
    set_homepage("https://github.com/Edersteiner/xrefl")
    set_description("A general-purpose C++ reflection and code generation plugin for XMake")
    set_license("0BSD")

    add_urls("https://github.com/Edersteiner/xrefl/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Edersteiner/xrefl.git",
             {version = function (version) return "v" .. version end})
    add_versions("0.2.0", "2c71f3bcb86a5a824c9dce2fa3194179f063955bd6c8ac17d8f142dfa9bd92f1")

    on_install("@windows", "@linux", "@macosx", function (package)
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        os.vrun("xrefl --version")
    end)
