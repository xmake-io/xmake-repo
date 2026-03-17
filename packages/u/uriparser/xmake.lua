package("uriparser")
    set_homepage("https://uriparser.github.io/")
    set_description("uriparser is a strictly RFC 3986 compliant URI parsing and handling library written in C89.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/uriparser/uriparser/archive/refs/tags/uriparser-$(version).tar.gz",
             "https://github.com/uriparser/uriparser.git")

    add_versions("0.9.8", "d6289387eaf2495e38ed80d709ad673fe04d63fad707badfee96f3d2dabc7c35")
    add_versions("0.9.7", "8e19250654a204af0858408b55dc78941382a8c824bf38fc7f2a95ca6e16d7a0")
    add_versions("0.9.6", "defaf550bf6fe05e89afb9814dccc6bd643a3b0a8308801a2c04b76682b87383")
    add_versions("0.9.5", "dece5067b4517c4b16cde332c491b4b3508249d2a8f4ba393229575d3c5241c0")

    add_deps("cmake")

    on_load(function (package)
        if not package:config("shared") then
            package:add("defines", "URI_STATIC_BUILD")
        end
    end)

    on_install(function (package)
        local configs = {"-DURIPARSER_BUILD_DOCS=OFF", "-DURIPARSER_BUILD_TESTS=OFF", "-DURIPARSER_BUILD_TOOLS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DURIPARSER_MSVC_RUNTIME=/" .. package:runtimes())
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("uriParseSingleUriA", {includes = "uriparser/Uri.h"}))
    end)
