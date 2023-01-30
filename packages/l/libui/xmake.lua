package("libui")
    set_homepage("https://libui-ng.github.io/libui-ng/")
    set_description("A portable GUI library for C")

    set_urls("https://github.com/libui-ng/libui-ng.git")
    add_versions("2022.12.3", "8c82e737eea2f8ab3667e227142abd2fd221f038")

    add_deps("meson", "ninja")

    on_install(function (package)
        local config = { "-Dexamples=false", "-Dtests=false" }
        table.insert(config, "--default-library=" .. (package:config("shared") and "shared" or "static"))

        import("package.tools.meson").install(package, config)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
        #include <stdio.h>
        #include <ui.h>

        int onClosing(uiWindow *w, void *data)
        {
            uiQuit();
            return 1;
        }

        void test(void)
        {
            uiInitOptions o = {0};
            const char *err;
            uiWindow *w;
            uiLabel *l;

            err = uiInit(&o);
            if (err != NULL) {
                fprintf(stderr, "Error initializing libui-ng: %s\n", err);
                uiFreeInitError(err);
                return;
            }

            // Create a new window
            w = uiNewWindow("Hello World!", 300, 30, 0);
            uiWindowOnClosing(w, onClosing, NULL);

            l = uiNewLabel("Hello, World!");
            uiWindowSetChild(w, uiControl(l));

            uiControlShow(uiControl(w));
            uiMain();
            uiUninit();
        }
        ]]}, { configs = { languages = "c99" }, includes = "ui.h" }))
    end)
