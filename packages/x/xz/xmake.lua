package("xz")

    set_homepage("https://tukaani.org/xz/")
    set_description("General-purpose data compression with high compression ratio.")

    set_urls("https://downloads.sourceforge.net/project/lzmautils/xz-$(version).tar.gz",
             "https://tukaani.org/xz/xz-$(version).tar.gz")
    add_versions("5.2.4", "b512f3b726d3b37b6dc4c8570e137b9311e7552e8ccbab4d39d47ce5f4177145")

    on_load(function (package)
        if is_plat(os.host()) then
            package:addenv("PATH", "bin")
        end
    end)

    on_install("macosx", "linux", "mingw@linux,macosx", function (package)
        local configs = {"--disable-dependency-tracking", "--disable-silent-rules"}
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
        else
            table.insert(configs, "--enable-shared=no")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        if is_plat(os.host()) then
            os.vrun("xz --version")
        end
        assert(package:has_cfuncs("lzma_code", {includes = "lzma.h"}))
    end)
