package("chromium_zlib")

    set_homepage("https://chromium.googlesource.com/chromium/src/third_party/zlib/")
    set_description("zlib from chromium")
    set_license("zlib")

    add_urls("https://github.com/xmake-mirror/chromium_zlib.git")
    add_urls("https://chromium.googlesource.com/chromium/src/third_party/zlib.git")
    add_versions("2022.02.22", "6f44c22c1f003bd20011062abec283678842567c")
    add_versions("2023.03.14", "5edb52d4302d7aef232d585ec9ae27ef5c3c5438")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    if is_plat("linux") then
        add_syslinks("pthread")
    end

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
