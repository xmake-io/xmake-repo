package("zziplib")

    set_homepage("http://zziplib.sourceforge.net/")
    set_description("The zziplib library is intentionally lightweight, it offers the ability to easily extract data from files archived in a single zip file.")
    set_license("GPL-2.0")

    add_urls("https://github.com/gdraheim/zziplib/archive/refs/tags/$(version).tar.gz",
             "https://github.com/gdraheim/zziplib.git")
    add_versions("v0.13.76", "08b0e300126329c928a41b6d68e397379fad02469e34a0855d361929968ea4c0")
    add_versions("v0.13.74", "319093aa98d39453f3ea2486a86d8a2fab2d5632f6633a2665318723a908eecf")
    add_versions("v0.13.72", "93ef44bf1f1ea24fc66080426a469df82fa631d13ca3b2e4abaeab89538518dc")
    add_versions("v0.13.73", "2aa9d317f70060101064863e4e8fe698c32301e2d293d2b4964608cf2d5b2d8b")

    add_deps("cmake", "zlib")
    on_install("windows", "macosx", "linux", function (package)
        io.replace("zzip/CMakeLists.txt", "include ( CodeCoverage )", "", {plain = true})
        local configs = {"-DZZIPTEST=OFF", "-DZZIPDOCS=OFF", "-DZZIPWRAP=OFF", "-DZZIPSDL=OFF", "-DZZIPMMAPPED=OFF", "-DZZIPFSEEKO=OFF", "-DZZIPBINS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_STATIC_LIBS=" .. (package:config("shared") and "OFF" or "ON"))
        if package:is_plat("windows") then
            table.insert(configs, "-DMSVC_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        if package:config("pic") ~= false then
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("zzip_open", {includes = "zzip/zzip.h"}))
    end)
