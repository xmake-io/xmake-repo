package("serial-monitor")
    set_kind("addon")
    set_homepage("https://github.com/xmake-addons/serial-monitor-plugin")
    set_description("Monitor the serial port output.")

    add_urls("https://github.com/xmake-addons/serial-monitor-plugin/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xmake-addons/serial-monitor-plugin.git")
    add_versions("v1.0.1", "decc4997060106551fd2e011748f610d77190b425ef9ef3e8ba55dd686382aa4")

    on_test(function (package)
        os.vrun("xmake monitor --help")
    end)
