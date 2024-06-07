package("kuba-zip")
    set_homepage("https://github.com/kuba--/zip")
    set_description("A portable, simple zip library written in C")
    set_license("Unlicense")

    add_urls("https://github.com/kuba--/zip/archive/refs/tags/$(version).tar.gz",
             "https://github.com/kuba--/zip.git")

    add_versions("v0.3.2", "0c33740aec7a3913bca07df360420c19cac5e794e0f602f14f798cb2e6f710e5")
    add_versions("v0.3.1", "775b8a44b53e72a55c13839bf507219c2cf30b26f62e70f1a20bb727db54438f")
    add_versions("v0.2.2", "f278b1da5e5382c7a1a1db1502cfa1f6df6b1e05e36253d661344d30277f9895")
    add_versions("v0.2.5", "e052f6cbe6713f69f8caec61214fda4e5ae5150d1fcba02c9e79f1a05d939305")
    add_versions("v0.2.6", "6a00e10dc5242f614f76f1bd1d814726a41ee6e3856ef3caf7c73de0b63acf0b")

    add_deps("cmake")

    on_install("windows", "macosx", "linux", "mingw", function (package)
        io.replace("CMakeLists.txt", "-Werror", "", {plain = true})

        local configs = {"-DCMAKE_DISABLE_TESTING=ON", "-DZIP_BUILD_DOCS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.insert(configs, "-DBUILD_SHARED_LIBS=ON")
            if package:is_plat("windows", "mingw") then
                package:add("defines", "ZIP_SHARED")
            end
        else
            table.insert(configs, "-DBUILD_SHARED_LIBS=OFF")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("zip_open", {includes = "zip/zip.h"}))
    end)
