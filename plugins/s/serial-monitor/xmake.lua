package("serial-monitor")
    set_kind("plugin")
    set_homepage("https://github.com/xmake-io/serial-monitor-plugin")
    set_description("Monitor the serial port output.")

    add_urls("https://github.com/xmake-io/serial-monitor-plugin/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xmake-io/serial-monitor-plugin.git")
    add_versions("v1.0.0", "0505aace0033cc740b9a0f309bd4832b64f50cf1068e0f5f843ea084bfa97bd0")

    on_test(function (package)
        os.vrun("xmake monitor --help")
    end)
