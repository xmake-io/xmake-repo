package("xmake-harness")
    set_kind("addon")
    set_homepage("https://github.com/xmake-addons/xmake-harness")
    set_description("A generic AI agent harness framework and the `xmake ai` terminal assistant, with the first-class xmake build enhancement.")
    set_license("Apache-2.0")

    add_urls("https://github.com/xmake-addons/xmake-harness/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xmake-addons/xmake-harness.git")
    add_versions("v1.0.0", "44a0b3369ed6d2fc4458b0741ebc264c3bfe62de6749200c3498944811212daa")
    add_versions("v1.0.1", "aefa5d431efc73ae946480cb7e61fa22a342dd1055c05120a4dac40f044550c9")
    add_versions("v1.0.2", "a22f6a2aad36dbfe2baf0d83a16ae46df551ab5c92a79d12ae57705449e817bf")

    on_test(function (package)
        assert(package:has_addon({plugins = "ai", modules = "harness"}))

        -- @note we only show the menu here, the agent needs an api key and the network
        os.vrun("xmake ai --help")
    end)
