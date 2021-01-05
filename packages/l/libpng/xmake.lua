package("libpng")

    set_homepage("http://www.libpng.org/pub/png/libpng.html")
    set_description("The official PNG reference library")

    set_urls("https://github.com/glennrp/libpng/archive/$(version).zip",
             "https://github.com/glennrp/libpng.git")
    add_versions("v1.6.37", "c2c50c13a727af73ecd3fc0167d78592cf5e0bca9611058ca414b6493339c784")
    add_versions("v1.6.36", "6274d3f761cc80f7f6e2cde6c07bed10c00bc4ddd24c4f86e25eb51affa1664d")
    add_versions("v1.6.35", "3d22d46c566b1761a0e15ea397589b3a5f36ac09b7c785382e6470156c04247f")
    add_versions("v1.6.34", "7ffa5eb8f9f3ed23cf107042e5fec28699718916668bbce48b968600475208d3")
    set_license("libpng-2.0")

    add_deps("zlib")
    if is_plat("windows", "mingw") then
        add_deps("cmake >3.12")
    end

    on_install("windows", "mingw", function (package)
        local configs = {"-DPNG_TESTS=OFF", "-DPNG_BUILD_ZLIB=ON", "-DPNG_EXECUTABLES=OFF",
                         "-DPNG_SHARED=" .. (package:config("shared") and "ON" or "OFF"),
                         "-DPNG_STATIC=" .. (package:config("shared") and "OFF" or "ON"),
                         "-DPNG_DEBUG=" .. (package:debug() and "ON" or "OFF")}
        local zlib = assert(package:dep("zlib"):fetch(), "zlib not found!")
        io.replace("CMakeLists.txt", "${ZLIB_LIBRARY}", table.unwrap(zlib.links), {plain = true})
        import("package.tools.cmake").install(package, configs, {packagedeps = "zlib"})
    end)

    on_install("iphoneos", "android@linux,macosx", "macosx", "linux", function (package)
        import("package.tools.autoconf")
        local zlib = package:dep("zlib")
        local envs = autoconf.buildenvs(package)
        if zlib then
            -- we need patch cflags to cppflags for supporting zlib on android ndk
            -- @see https://github.com/xmake-io/xmake/issues/1126
            envs.CPPFLAGS = (envs.CFLAGS or "") .. " -I" .. os.args(path.join(zlib:installdir(), "include"))
            envs.LDFLAGS = (envs.LDFLAGS or "") .. " -L" .. os.args(path.join(zlib:installdir(), "lib"))
        end
        local configs = {"--disable-dependency-tracking", "--disable-silent-rules"}
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
            table.insert(configs, "--enable-static=no")
        else
            table.insert(configs, "--enable-static=yes")
            table.insert(configs, "--enable-shared=no")
        end
        autoconf.install(package, configs, {envs = envs})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("png_create_read_struct", {includes = "png.h"}))
    end)
