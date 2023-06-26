package("kuba-zip")

    set_homepage("https://github.com/kuba--/zip")
    set_description("A portable, simple zip library written in C")

    add_urls("https://github.com/kuba--/zip/archive/refs/tags/$(version).tar.gz",
             "https://github.com/kuba--/zip.git")
    add_versions("v0.2.2", "f278b1da5e5382c7a1a1db1502cfa1f6df6b1e05e36253d661344d30277f9895")
    add_versions("v0.2.5", "e052f6cbe6713f69f8caec61214fda4e5ae5150d1fcba02c9e79f1a05d939305")

    add_deps("cmake")
    on_load("windows", "mingw@windows", function (package)
        if package:config("shared") then
            package:add("defines", "ZIP_SHARED")
        end
    end)

    on_install("windows", "macosx", "linux", "mingw@windows", function (package)
        local configs = {"-DCMAKE_DISABLE_TESTING=ON", "-DZIP_BUILD_DOCS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("zip_open", {includes = "zip/zip.h"}))
    end)
