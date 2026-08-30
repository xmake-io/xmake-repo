package("stm32-devel")
    set_kind("addon")
    set_homepage("https://github.com/xmake-addons/stm32-devel")
    set_description("The STM32 development addon, it provides the toolchain, the build rules and the project templates of the STM32 boards.")
    set_license("Apache-2.0")

    add_urls("https://github.com/xmake-addons/stm32-devel/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xmake-addons/stm32-devel.git")
    add_versions("v1.0.0", "a380faf5f9640fc63f899e034d77019a68308b99b229e711900a06c5c3f0e3c0")

    add_deps("serial-tools", {kind = "addon"})

    on_test(function (package)
        assert(package:has_addon({
            rules      = "app",
            toolchains = "stm32",
            templates  = "c/stm32.blink"}))

        os.vrunv("xmake", {"create", "-t", "stm32.blink", "test"})
    end)
