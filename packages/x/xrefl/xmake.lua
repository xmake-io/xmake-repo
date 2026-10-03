package("xrefl")
    set_kind("binary")
    set_homepage("https://github.com/Edersteiner/xrefl")
    set_description("A general-purpose C++ reflection and code generation plugin for XMake")
    set_license("0BSD")

    add_urls("https://github.com/Edersteiner/xrefl/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Edersteiner/xrefl.git",
             {version = function (version) return "v" .. version end})
    add_versions("0.2.1", "f1998b47c91a2d5a2fe9972e2d8cd3b3b5588ddf7a3eb93d321530c3b682fa38")

    on_install("@windows", "@linux", "@macosx", function (package)
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        os.vrun("xrefl --version")
    end)
