package("xrefl")
    set_kind("binary")
    set_homepage("https://github.com/Edersteiner/xrefl")
    set_description("A general-purpose C++ reflection and code generation plugin for XMake")
    set_license("0BSD")

    add_urls("https://github.com/Edersteiner/xrefl/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Edersteiner/xrefl.git",
             {version = function (version) return "v" .. version end})
    add_versions("0.1.0", "6f930dfd29ca44ab55d8afa661ad31153d53a4dae3cca7d4ce463b19afd042e3")

    on_install("@windows", "@linux", "@macosx", function (package)
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        os.vrun("xrefl --version")
    end)
