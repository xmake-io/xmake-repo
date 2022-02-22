package("chromium_zlib")

    set_homepage("https://chromium.googlesource.com/chromium/src/third_party/zlib/")
    set_description("zlib from chromium")
    set_license("zlib")

    add_urls("https://github.com/xq114/chromium_zlib.git")
    add_urls("https://chromium.googlesource.com/chromium/src/third_party/zlib.git")
    add_versions("2022.02.22", "f8d70d13465e79ff7513aafe3a0f4374271fbade")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    on_install(function (package)
        for _, f in ipairs(table.join(os.files("contrib/minizip/*.c"), os.files("contrib/minizip/*.h"))) do
            io.replace(f, "third_party/zlib/zlib.h", "zlib.h", {plain = true})
        end
        os.cp(path.join(os.scriptdir(), "port", "xmake.lua"), ".")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("inflate", {includes = "zlib.h"}))
    end)
