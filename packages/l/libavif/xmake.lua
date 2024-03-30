package("libavif")

    set_homepage("https://github.com/AOMediaCodec/libavif")
    set_description("libavif - Library for encoding and decoding .avif files")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/AOMediaCodec/libavif/archive/refs/tags/$(version).tar.gz",
             "https://github.com/AOMediaCodec/libavif.git")
    add_versions("v1.0.4", "dc56708c83a4b934a8af2b78f67f866ba2fb568605c7cf94312acf51ee57d146")
    add_versions("v0.9.1", "8526f3fff34a05a51d7c703cdcf1d0d38c939b5b6dd4bb7d3a3405ddad88186c")

    add_configs("dav1d", {description = "Use the dav1d codec for decoding.", default = false, type = "boolean"})

    add_deps("cmake")
    on_load(function (package)
        if package:config("dav1d") then
            package:add("deps", "dav1d")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DAVIF_ENABLE_WERROR=OFF", "-DAVIF_BUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("dav1d") then
            table.insert(configs, "-DAVIF_CODEC_DAV1D=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("avifImageCreate", {includes = "avif/avif.h"}))
    end)
