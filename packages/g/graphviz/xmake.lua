package("graphviz")

    set_homepage("https://www.graphviz.org/")
    set_description("Graph visualization software from AT&T and Bell Labs")
    set_license("EPL-1.0")

    add_urls("https://gitlab.com/graphviz/graphviz/-/archive/$(version)/graphviz-$(version).tar.gz",
             "https://gitlab.com/graphviz/graphviz.git")
    add_versions("2.48.0", "85a2beca9a1a58da3ba7237a63aad2e612f7e3afa990591a9971d2077f1f5937")

    add_deps("autoconf", "automake", "libtool", "pkg-config")
    if is_host("macosx") then
        add_deps("bison", {system = false})
    else
        add_deps("bison")
    end

    on_install(function (package)
        local configs = {"--disable-debug",
                         "--disable-dependency-tracking",
                         "--disable-php",
                         "--disable-swig",
                         "--disable-tcl",
                         "--without-freetype2",
                         "--without-gdk",
                         "--without-gdk-pixbuf",
                         "--without-gtk",
                         "--without-poppler",
                         "--without-qt",
                         "--without-x",
                         "--without-gts",
                         "--without-libgd",
                         "--without-glut",
                         "--without-rsvg",
                         "--without-pangocairo"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        if package:is_plat("macosx") then
            table.insert(configs, "--with-quartz")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
    end)
