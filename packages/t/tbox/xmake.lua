package("tbox")

    set_homepage("http://www.tboox.org")
    set_description("A glib-like multi-platform c library")

    add_urls("https://github.com/tboox/tbox/archive/$(version).zip")
    add_urls("https://github.com/tboox/tbox.git")
    add_urls("https://gitlab.com/tboox/tbox.git")
    add_urls("https://gitee.com/tboox/tbox.git")

    add_versions("v1.6.2", "5236090b80374b812c136c7fe6b8c694418cbfc9c0a820ec2ba35ff553078c7b")
    add_versions("v1.6.3", "bc5a957cdb1610c19f0cf94497ad114a0e01fd7d569777e9cb2133c513ef6baa")

    on_build(function (package)
        import("package.builder.xmake").build(package)
    end)

    on_install(function (package)
        import("package.builder.xmake").install(package)
    end)
