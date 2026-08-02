task("monitor")
    set_category("plugin")
    on_run("main")
    set_menu {
        usage = "xmake monitor [options]",
        description = "Monitor the serial port output.",
        options = {
            {'p', "port",     "kv", nil,      "Set the serial port to monitor.",
                                              "auto-detected when not specified, e.g.",
                                              "    - macOS:   /dev/cu.usbserial-0001",
                                              "    - Linux:   /dev/ttyUSB0",
                                              "    - Windows: COM3"},
            {'b', "baud",     "kv", "115200", "Set the baud rate."},
            {'d', "databits", "kv", "8",      "Set the data bits.",
                                              values = {"5", "6", "7", "8"}},
            {nil, "parity",   "kv", "none",   "Set the parity.",
                                              values = {"none", "even", "odd"}},
            {'s', "stopbits", "kv", "1",      "Set the stop bits.",
                                              values = {"1", "2"}},
            {'l', "list",     "k",  nil,      "List the available serial ports."}
        }
    }
