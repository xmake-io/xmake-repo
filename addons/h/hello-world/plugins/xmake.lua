task("hello")
    set_category("plugin")
    on_run("main")
    set_menu {
        usage = "xmake hello [options]",
        description = "Say hello to the world.",
        options = {
            {'n', "name", "kv", nil, "Set the name to say hello to."}
        }
    }
