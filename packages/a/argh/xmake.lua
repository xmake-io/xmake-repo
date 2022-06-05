package("argh")
    set_homepage("https://github.com/adishavit/argh")
    set_description("Argh! A minimalist argument handler.")
    set_license("BSD-3-Clause")

    set_urls("https://github.com/adishavit/argh.git")
    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package)
    end)
package_end()
