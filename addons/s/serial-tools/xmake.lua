package("serial-tools")
    set_kind("addon")
    set_homepage("https://github.com/xmake-addons/serial-tools")
    set_description("The serial port toolkit, it provides the `xmake monitor` command and the serial module.")

    add_urls("https://github.com/xmake-addons/serial-tools/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xmake-addons/serial-tools.git")
    add_versions("v1.0.3", "0504b8fdeaaef31583ea6edb525e84efa06850ee5ce592dbb8368c099af8b4e8")
    add_versions("v1.0.4", "fdd23f49ffc8cce31d9d6aba4047f188fddb72c343cf3454d01adca6c5e441ba")

    on_test(function (package)
        assert(package:has_addon({plugins = "monitor", modules = "serial"}))

        os.vrun("xmake monitor --help")
        os.vrunv("xmake", {"lua", "-c", [[
            import("@addon.serial-tools.serial")
            assert(type(serial.ports()) == "table")
            assert(serial.monitor and serial.resolve_port)
        ]]})
    end)
