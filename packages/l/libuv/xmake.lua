package("libuv")

    set_homepage("http://libuv.org/")
    set_description("A multi-platform support library with a focus on asynchronous I/O.")

    set_urls("https://github.com/libuv/libuv/archive/$(version).zip",
             "https://github.com/libuv/libuv.git")
    -- checksum sha256
    add_versions("v1.24.0", "e22ecac6b2370ce7bf7b0cff818e44cdaa7d0b9ea1f8d6d4f2e0aaef43ccf5d7")
    add_versions("v1.23.2", "0bb546e7cfa2a4e7576d66d0622bffb0a8111f9669f6131471754a1b68f6f754")
    add_versions("v1.23.1", "fc0de9d02cc09eb00c576e77b29405daca5ae541a87aeb944fee5360c83b9f4c")
    add_versions("v1.23.0", "ffa1aacc9e8374b01d1ff374b1e8f1e7d92431895d18f8e9d5e59a69a2a00c30")
    add_versions("v1.22.0", "1e8e51531732f8ef5867ae3a40370814ce2e4e627537e83ca519d40b424dced0")

    if is_host("windows") then
        add_deps("cmake")
    else
        add_deps("autoconf", "automake", "libtool", "pkg-config")
    end

    on_load("windows", function (package)
        package:addvar("links", "uv_a")
        package:addvar("syslinks", "advapi32", "iphlpapi", "psapi", "user32", "userenv", "ws2_32", "kernel32", "gdi32", "winspool", "shell32", "ole32", "oleaut32", "uuid", "comdlg32")
    end)

    on_install("windows", function (package)
        local configs = {}
        local rtlib = string.lower(package:config('mtlib') or '')
        if rtlib == 'md' then
            configs = {
                '-DCMAKE_CXX_FLAGS_DEBUG="/MDd"',
                '-DCMAKE_CXX_FLAGS_RELEASE="/MD"',
                '-DCMAKE_C_FLAGS_DEBUG="/MDd"',
                '-DCMAKE_C_FLAGS_RELEASE="/MD"'
            }
        else
            -- default "runtime library" setting of libuv is md, it's conflict with default linke behavior
            configs = {
                '-DCMAKE_CXX_FLAGS_DEBUG="/MTd"',
                '-DCMAKE_CXX_FLAGS_RELEASE="/MT"',
                '-DCMAKE_C_FLAGS_DEBUG="/MTd"',
                '-DCMAKE_C_FLAGS_RELEASE="/MT"'
            }
        end
        import("package.tools.cmake").install(package, configs)
        os.cp("include", package:installdir())
    end)

    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf").install(package)
    end)
