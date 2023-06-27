package("libuv")

    set_homepage("http://libuv.org/")
    set_description("A multi-platform support library with a focus on asynchronous I/O.")
    set_license("MIT")

    set_urls("https://github.com/libuv/libuv/archive/$(version).zip",
             "https://github.com/libuv/libuv.git")
    add_versions("v1.44.1", "d233a9c522a9f4afec47b0d12f302d93d114a9e3ea104150e65f55fd931518e6")
    add_versions("v1.42.0", "031130768b25ae18c4b9d4a94ba7734e2072b11c6fce3e554612c516c3241402")
    add_versions("v1.41.0", "cb89a8b9f686c5ccf7ed09a9e0ece151a73ebebc17af3813159c335b02181794")
    add_versions("v1.40.0", "61366e30d8484197dc9e4a94dbd98a0ba52fb55cb6c6d991af1f3701b10f322b")
    add_versions("v1.28.0", "e7b3caea3388a02f2f99e61f9a71ed3e3cbb88bbb4b0b630d609544099b40674")
    add_versions("v1.27.0", "02d4a643d5de555168f2377961aff844c3037b44c9d46eb2019113af62b3cf0a")
    add_versions("v1.26.0", "b9b6ae976685a406e63d88084d99fc7cc792c3226605a840fea87a450fe26f16")
    add_versions("v1.25.0", "07aa196518b786bb784ab224d6300e70fcb0f35a98180ecdc4a672f0e160728f")
    add_versions("v1.24.1", "a8dd045466d74c0244efc35c464579a7e032dd92b0217b71596535d165de4f07")
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

    if is_plat("macosx", "iphoneos") then
        add_frameworks("CoreFoundation")
    elseif is_plat("linux") then
        add_syslinks("pthread", "dl")
    elseif is_plat("windows", "mingw") then
        add_syslinks("advapi32", "iphlpapi", "psapi", "user32", "userenv", "ws2_32", "kernel32", "gdi32", "winspool", "shell32", "ole32", "oleaut32", "uuid", "comdlg32")
    end

    on_load("windows", function (package)
        package:add("links", "uv" .. (package:config("shared") and "" or "_a"))
        if package:config("shared") then
            package:add("defines", "USING_UV_SHARED")
        end
        if package:version():ge("1.40") and package:version():lt("1.44") then
            package:add("linkdirs", path.join("lib", package:debug() and "Debug" or "Release"))
        end
    end)

    on_install("windows", function (package)
        local configs = {"-DLIBUV_BUILD_TESTS=OFF", "-DLIBUV_BUILD_BENCH=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
        if package:version():lt("1.40") then
            os.cp("include", package:installdir())
        end
    end)

    on_install("macosx", "linux", "android@linux,macosx", "mingw@linux,macosx", function (package)
        local configs = {}
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
        else
            table.insert(configs, "--enable-shared=no")
        end
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        if package:is_plat("iphoneos") and package:version():ge("1.40") and package:version():lt("1.44") then
            -- fix CoreFoundation type definition
            io.replace("src/unix/darwin.c", "!TARGET_OS_IPHONE", "1", {plain = true})
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("uv_tcp_init", {includes = "uv.h"}))
    end)
