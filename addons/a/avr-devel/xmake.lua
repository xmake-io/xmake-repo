package("avr-devel")
    set_kind("addon")
    set_homepage("https://github.com/xmake-addons/avr-devel")
    set_description("The AVR development addon, it provides the toolchain, the build rules and the project templates of the 8-bit AVR boards.")
    set_license("Apache-2.0")

    add_urls("https://github.com/xmake-addons/avr-devel/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xmake-addons/avr-devel.git")
    add_versions("v1.0.0", "24b49fdbbb7d5348df24df70360706b6aa9ec4e10b977091e4102cc78b2ebf9c")

    add_deps("serial-tools", {kind = "addon"})

    on_test(function (package)
        assert(package:has_addon({
            rules      = "app",
            toolchains = "avr",
            templates  = "c/avr.blink"}))

        os.vrunv("xmake", {"create", "-t", "avr.blink", "test"})
    end)
