package("zziplib")

    set_homepage("http://zziplib.sourceforge.net/")
    set_description("The zziplib library is intentionally lightweight, it offers the ability to easily extract data from files archived in a single zip file.")
    set_license("GPL-2.0")

    add_urls("https://github.com/gdraheim/zziplib/archive/refs/tags/$(version).tar.gz",
             "https://github.com/gdraheim/zziplib.git")
    add_versions("v0.13.72", "93ef44bf1f1ea24fc66080426a469df82fa631d13ca3b2e4abaeab89538518dc")

    add_deps("cmake", "zlib")
    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DZZIPTEST=OFF", "-DZZIPDOCS=OFF", "-DZZIPWRAP=OFF", "-DZZIPSDL=OFF", "-DZZIPMMAPPED=OFF", "-DZZIPFSEEKO=OFF", "-DZZIPBINS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_STATIC_LIBS=" .. (package:config("shared") and "OFF" or "ON"))
        if package:is_plat("windows") then
            table.insert(configs, "-DMSVC_STATIC_RUNTIME=" .. ((package:config("runtimes") and package:has_runtime("MT", "MTd")) or (package:config("vs_config") and package:config("vs_config"):startswith("MT")) and "ON" or "OFF"))
        end
        if package:config("pic") ~= false then
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("zzip_open", {includes = "zzip/zzip.h"}))
    end)
