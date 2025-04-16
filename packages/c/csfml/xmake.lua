package("csfml")
    set_homepage("https://www.sfml-dev.org/")
    set_description("CSFML - Official C binding for SFML")
    set_license("zlib")

    add_urls("https://github.com/SFML/CSFML/archive/refs/tags/$(version).tar.gz")
    add_versions("2.6.1", "f3f3980f6b5cad85b40e3130c10a2ffaaa9e36de5f756afd4aacaed98a7a9b7b")

    add_deps("cmake")
    add_deps("sfml =2.6.1")

    on_install(function (package)
        local configs = {
            "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"),
            "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"),
            "-DCSFML_LINK_SFML_STATICALLY=OFF"
        }

        local sfml = package:dep("sfml")
        if sfml then
            table.insert(configs, "-DSFML_DIR=" .. sfml:installdir() .. "/lib/cmake/SFML")
        end

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("sfWindow_create", {includes = "SFML/Window.h"}))
    end)
