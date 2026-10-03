package("timeh")
    set_homepage("https://github.com/Monjaris/timeh")
    set_description("A simple terminal time utility")
    set_license("MIT")

    add_urls("https://github.com/Monjaris/timeh/archive/refs/tags/v$(version).tar.gz")
    add_versions("0.5.0", "f146f4b17ff83ef72ca7ea6958fda016a660e38732f9f9e452f176a23c233d85")

    set_kind("binary")

    on_install(function(package)
        import("package.tools.xmake").install(package)
    end)

    on_test(function(package)
        os.vexec("timeh")
    end)
