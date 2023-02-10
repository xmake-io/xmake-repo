package("pigz")
    set_kind("binary")
    set_homepage("http://zlib.net/pigz/")
    set_description("A parallel implementation of gzip for modern multi-processor, multi-core machines.")

    add_urls("https://github.com/madler/pigz.git")
    add_versions("2022.01.15", "cb8a432c91a1dbaee896cd1ad90be62e5d82d452")

    add_deps("zlib")

    on_install("linux", "macosx", "bsd", function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            add_requires("zlib")
            target("pigz")
               set_kind("binary")
               add_files("**.c")
               add_syslinks("pthread", "dl")
               add_packages("zlib")
        ]])
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        os.vrun("pigz --help")
    end)
