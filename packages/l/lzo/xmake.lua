package("lzo")

    set_homepage("http://www.oberhumer.com/opensource/lzo")
    set_description("LZO is a portable lossless data compression library written in ANSI C.")
    set_license("GPL-2.0")

    add_urls("http://www.oberhumer.com/opensource/lzo/download/lzo-$(version).tar.gz")
    add_versions("2.10", "c0f892943208266f9b6543b3ae308fab6284c5c90e627931446fb49b4221a072")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DENABLE_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lzo_version", {includes = "lzo/lzo1x.h"}))
    end)