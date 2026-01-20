package("libuv")
    set_homepage("http://libuv.org/")
    set_description("A multi-platform support library with a focus on asynchronous I/O.")
    set_license("MIT")

    set_urls("https://github.com/libuv/libuv/archive/refs/tags/$(version).zip",
             "https://github.com/libuv/libuv.git")

    add_versions("v1.51.0", "54e1e108c54b2d1dcaee0d16721385404fc95cc2a2cd2deb51e3529c202d6455")
    add_versions("v1.50.0", "038f48e48b3d15c9341dfe1fa5099b83b52ac30f15c97a67269163f8f8ab99ac")
    add_versions("v1.49.2", "9050042ac6cbd85c644e38c23a67e9f8a9d32eafe71479bbea674b4125489141")
    add_versions("v1.49.1", "94312ede44c6cae544ae316557e2651aea65efce5da06f8d44685db08392ec5d")
    add_versions("v1.49.0", "99378c7911af3f0141b085aa59feb76ff54885e4bbc516be677c06c952fb9fa0")
    add_versions("v1.48.0", "6dd637af0c23bee06b685a94e22f7e695f4ea7a9ab705485e32e658d4fd0125b")
    add_versions("v1.47.0", "d50af7e6d72526db137e66fad812421c8a1cae09d146b0ec2bb9a22c5f23ba93")
    add_versions("v1.46.0", "45953dc9b64db7f4f47561f9e4543b762c52adfe7c9b6f8e9efbc3b4dd7d3081")
    add_versions("v1.45.0", "969d2c7c1110c5c47666a149501f29f7e4948c4a5b4add0f8ffe6b2203282638")
    add_versions("v1.44.1", "d233a9c522a9f4afec47b0d12f302d93d114a9e3ea104150e65f55fd931518e6")
    add_versions("v1.43.0", "5d60a506981bcb340333b9d47d5faa8a49f2382da33073972383a02f79173b7b")
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

    add_patches("1.44.1", "https://github.com/libuv/libuv/pull/3563/commits/88930d52c1dd60f87445fdc26f0c22b2078299ea.patch", "ab61f14e35fbf6f54c854484b3766046da2dd0368bf71ec12471b89dd3739b1d")

    if is_plat("macosx", "iphoneos") then
        add_frameworks("CoreFoundation")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread", "dl")
    elseif is_plat("windows", "mingw") then
        add_syslinks("advapi32", "iphlpapi", "psapi", "user32", "userenv", "ws2_32", "shell32", "ole32", "uuid", "dbghelp")
    end

    -- https://github.com/libuv/libuv/issues/3411
    if on_check then
        on_check("android", function (package)
            if package:version():ge("1.45.0") then
                local ndk = package:toolchain("ndk")
                local ndk_sdkver = ndk:config("ndk_sdkver")
                assert(ndk_sdkver and tonumber(ndk_sdkver) >= 24, "package(libuv): need ndk api level >= 24 after v1.45.0")
            end
        end)
    end

    on_load(function (package)
        local version = package:version()
        if version:ge("1.42.0") or is_host("windows") then
            package:add("deps", "cmake")
        else
            package:add("autoconf", "automake", "libtool", "pkg-config")
        end

        if package:is_plat("windows") then
            if version:eq("1.43.0") then
                package:config_set("shared", false)
                wprint("package(libuv/1.43.0) only support static library")
            end
            if version:ge("1.45") then
                package:add("links", package:config("shared") and "uv" or "libuv")
            else
                package:add("links", package:config("shared") and "uv" or "uv_a")
            end
            if package:config("shared") then
                package:add("defines", "USING_UV_SHARED")
            end
            if version:ge("1.40") and version:lt("1.43") then
                package:add("linkdirs", path.join("lib", package:is_debug() and "Debug" or "Release"))
            end
        end
    end)

    on_install("!wasm", function (package)
        if package:is_plat("mingw") then
            io.replace("CMakeLists.txt", "CYGWIN OR MSYS", "FALSE", {plain = true})
        end

        local version = package:version()
        if version:ge("1.42.0") or is_host("windows") then
            local configs = {"-DLIBUV_BUILD_TESTS=OFF", "-DLIBUV_BUILD_BENCH=OFF"}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DLIBUV_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
            import("package.tools.cmake").install(package, configs)
            if version:lt("1.40") then
                os.cp("include", package:installdir())
            end
            os.tryrm(package:installdir("lib/pkgconfig/libuv-static.pc"))
            os.tryrm(package:installdir("lib/pkgconfig/libuv.pc"))
        else
            local configs = {}
            table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
            if package:is_plat("iphoneos") and version:ge("1.40") and version:lt("1.44") then
                -- fix CoreFoundation type definition
                io.replace("src/unix/darwin.c", "!TARGET_OS_IPHONE", "1", {plain = true})
            end
            import("package.tools.autoconf").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("uv_tcp_init", {includes = "uv.h"}))
    end)
