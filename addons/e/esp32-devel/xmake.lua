package("esp32-devel")
    set_kind("addon")
    set_homepage("https://github.com/xmake-addons/esp32-devel")
    set_description("The ESP32 development addon, it provides the toolchain, the build rules and the project templates of the esp32c3/esp32s3 boards.")
    set_license("Apache-2.0")

    add_urls("https://github.com/xmake-addons/esp32-devel/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xmake-addons/esp32-devel.git")
    add_versions("v1.0.4", "737c1f062a26c58b05daf60082aa91a3c3c37583d9f51083def8d5aa903bbf90")
    add_versions("v1.0.5", "0fc91165770a6f4d42438b188efd0ffd6b2f7eec6abf71919f2b727cf02bde9b")
    add_versions("v1.0.6", "9602118d49befafd065b1de0469c20d2fb02ce7e2e584c8432e412f5d6626622")

    add_deps("serial-tools", {kind = "addon"})

    on_test(function (package)
        assert(package:has_addon({
            rules      = "app",
            toolchains = "esp32",
            templates  = "c/esp32.blink"}))

        os.vrunv("xmake", {"create", "-t", "esp32.blink", "test"})
    end)
