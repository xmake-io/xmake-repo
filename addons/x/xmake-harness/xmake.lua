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
    add_versions("v1.0.3", "8c868e719fced4a098844b8d22b05ee3217c5b03a99c3e93a95aae553738302d")
    add_versions("v1.0.4", "dccea6db72729a47bcc81124907b1ec920437d3fd32e0efe1c24d697c7f8450b")
    add_versions("v1.0.5", "a01401dddf233be32dcb6867c1c4742dd2286491c5c0efa758b18243e6d3fab6")
    add_versions("v1.0.6", "c03dec3099be35f0f00177298f6fcb6ee6893e38a4affb3d2421468cbdc5cb2d")

    on_test(function (package)
        assert(package:has_addon({plugins = "ai", modules = "harness"}))

        -- @note we only show the menu here, the agent needs an api key and the network
        os.vrun("xmake ai --help")
    end)
