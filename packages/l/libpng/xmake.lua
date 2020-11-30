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
    if is_host("windows") then
        add_deps("cmake")
    end

    on_install("windows", function (package)
        local configs = {"-DPNG_TESTS=OFF",
                         "-DPNG_SHARED=" .. (package:config("shared") and "ON" or "OFF"),
                         "-DPNG_STATIC=" .. (package:config("shared") and "OFF" or "ON"),
                         "-DPNG_DEBUG=" .. (package:debug() and "ON" or "OFF")}
        import("package.tools.cmake").install(package, configs)
    end)

    on_install("macosx", "linux", function (package)
        local configs = {"--disable-dependency-tracking", "--disable-silent-rules"}
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
            table.insert(configs, "--enable-static=no")
        else
            table.insert(configs, "--enable-static=yes")
            table.insert(configs, "--enable-shared=no")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_install("iphoneos", "android@linux,macosx", function (package)
        import("package.tools.autoconf")
        local zlib = package:dep("zlib")
        local envs = autoconf.buildenvs(package)
        if zlib then
            envs.CPPFLAGS = (envs.CPPFLAGS or "") .. " -I" .. os.args(path.join(zlib:installdir(), "include"))
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
