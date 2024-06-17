package("nghttp3")
    set_homepage("https://github.com/ngtcp2/nghttp3")
    set_description("HTTP/3 library written in C")
    set_license("MIT")

    add_urls("https://github.com/ngtcp2/nghttp3/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ngtcp2/nghttp3.git")

    add_versions("v1.4.0", "522c8952ccae1815f34425f0c8bc6d8a4660e72dada1b4e97b8223e4c459a84a")
    add_versions("v1.3.0", "a83c6a4f589ae777a5f967652969d99b3399a85971340b8de9bed79119a11f88")

    add_patches("1.4.0", "patches/1.4.0/vendor.patch", "a6d611938c797d721a0345c5c772a1405ae0d6587ae46e16c1b73c89090a5c08")
    add_patches("1.3.0", "patches/1.3.0/vendor.patch", "51ab785328270b8df854283a8c20403c09813b0586eb84702a9c20241ff14980")

    add_deps("cmake", "sfparse")

    on_install(function (package)
        local configs = {"-DENABLE_LIB_ONLY=ON", "-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DENABLE_SHARED_LIB=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_STATIC_LIB=" .. (package:config("shared") and "OFF" or "ON"))
        if package:is_plat("windows") then
            table.insert(configs, "-DENABLE_STATIC_CRT=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = "sfparse"})
        if not package:config("shared") then
            package:add("defines", "NGHTTP3_STATICLIB")
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("nghttp3_version", {includes = "nghttp3/nghttp3.h"}))
    end)
