package("zziplib")
    set_homepage("http://zziplib.sourceforge.net/")
    set_description("The zziplib library is intentionally lightweight, it offers the ability to easily extract data from files archived in a single zip file.")
    set_license("GPL-2.0")

    add_urls("https://github.com/gdraheim/zziplib/archive/refs/tags/$(version).tar.gz",
             "https://github.com/gdraheim/zziplib.git")

    add_versions("v0.13.80", "21f40d111c0f7a398cfee3b0a30b20c5d92124b08ea4290055fbfe7bdd53a22c")
    add_versions("v0.13.79", "ed6f3017bb353b4a8f730c31a2fa065adb2d264c00d922aada48a5893eda26e4")
    add_versions("v0.13.78", "feaeee7c34f18aa27bd3da643cc6a47d04d2c41753a59369d09102d79b9b0a31")
    add_versions("v0.13.77", "50e166e6a879c2bd723e60e482a91ec793a7362fa2d9c5fe556fb0e025810477")
    add_versions("v0.13.76", "08b0e300126329c928a41b6d68e397379fad02469e34a0855d361929968ea4c0")
    add_versions("v0.13.74", "319093aa98d39453f3ea2486a86d8a2fab2d5632f6633a2665318723a908eecf")
    add_versions("v0.13.72", "93ef44bf1f1ea24fc66080426a469df82fa631d13ca3b2e4abaeab89538518dc")
    add_versions("v0.13.73", "2aa9d317f70060101064863e4e8fe698c32301e2d293d2b4964608cf2d5b2d8b")

    if is_plat("mingw") then
        add_patches("0.13.80", "patches/0.13.80/mingw-support.patch", "51f1e75249d7b493d269cce817e5e7ffa7aabffd28d72425381e11c1f256fe3d")
    end

    add_deps("cmake")
    add_deps("zlib")

    on_install(function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "ZZIP_DLL")
        end

        io.replace("zzip/CMakeLists.txt", "include ( CodeCoverage )", "", {plain = true})

        local configs = {"-DZZIPTEST=OFF", "-DZZIPDOCS=OFF", "-DZZIPWRAP=OFF", "-DZZIPSDL=OFF", "-DZZIPMMAPPED=OFF", "-DZZIPFSEEKO=OFF", "-DZZIPBINS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_STATIC_LIBS=" .. (package:config("shared") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("zzip_open", {includes = "zzip/zzip.h"}))
    end)
