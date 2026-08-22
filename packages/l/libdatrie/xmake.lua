package("libdatrie")

    set_homepage("https://github.com/tlwg/libdatrie")
    set_description("an implementation of double-array structure for representing trie")
    set_license("LGPL-2.1")

    add_urls("https://github.com/tlwg/libdatrie/releases/download/v$(version)/libdatrie-$(version).tar.xz")
    add_versions("0.2.14", "f04095010518635b51c2313efa4f290b7db828d6273e39b2b8858f859dfe81d5")
    add_versions("0.2.13", "12231bb2be2581a7f0fb9904092d24b0ed2a271a16835071ed97bed65267f4be")
    
    add_deps("m4", "pkg-config", "autoconf", "automake", "libtool")

    on_install("linux", function (package)
        local configs = {"--disable-dependency-tracking", "--disable-doxygen-doc"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("trie_new", {includes = "datrie/trie.h"}))
    end)
