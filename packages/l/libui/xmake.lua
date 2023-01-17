package("libui")
    set_homepage("https://libui-ng.github.io/libui-ng/")
    set_description("A portable GUI library for C")

    set_urls("https://github.com/libui-ng/libui-ng.git")
    add_versions("2022.12.3", "8c82e737eea2f8ab3667e227142abd2fd221f038")

    add_deps("meson", "ninja")

    on_install(function (package)
        import("package.tools.meson").install(package, {
            "-Dexamples=false",
            "-Dtests=false",
            "--default-library="..package:config("shared") and "shared" or "static",
        })
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

int main(void)
{
	uiInitOptions o = {0};
	const char *err;
	uiWindow *w;
	uiLabel *l;

	err = uiInit(&o);
	if (err != NULL) {
		fprintf(stderr, "Error initializing libui-ng: %s\n", err);
		uiFreeInitError(err);
		return 1;
	}

	// Create a new window
	w = uiNewWindow("Hello World!", 300, 30, 0);
	uiWindowOnClosing(w, onClosing, NULL);

	l = uiNewLabel("Hello, World!");
	uiWindowSetChild(w, uiControl(l));

	uiControlShow(uiControl(w));
	uiMain();
	uiUninit();
	return 0;
}
		]]}, { configs = { languages = "c99" }, includes = "ui.h" }))
    end)
