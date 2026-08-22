package("basic-templates")
    set_kind("addon")
    set_homepage("https://github.com/xmake-addons/basic-templates")
    set_description("The project templates that depend on external sdks or third-party libraries.")

    add_urls("https://github.com/xmake-addons/basic-templates/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xmake-addons/basic-templates.git")
    add_versions("v1.0.0", "64db580ac5bcf57365ff577ab36e8d1e84ad831babadabec0df6a92bdd98a12c")

    on_test(function (package)
        os.vrun("xmake create --list")
        os.vrun("xmake create -l c -t sdl sdlapp")
        os.vrun("xmake create -l c++ -t qt.widgetapp qtapp")
        os.vrun("xmake create -l verilog -t verilator.console vlapp")
    end)
