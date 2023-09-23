package("zopfli")
    set_homepage("https://github.com/google/zopfli")
    set_description("Zopfli Compression Algorithm is a compression library programmed in C to perform very good, but slow, deflate or zlib compression.")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/zopfli.git")
    add_versions("2021.06.14", "831773bc28e318b91a3255fa12c9fcde1606058b")

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DZOPFLI_BUILD_INSTALL=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ZopfliCompress", {includes = "zopfli.h"}))
    end)
