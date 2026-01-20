package("nghttp2")
    set_homepage("http://nghttp2.org/")
    set_description("nghttp2 is an implementation of HTTP/2 and its header compression algorithm HPACK in C.")
    set_license("MIT")

    add_urls("https://github.com/nghttp2/nghttp2/releases/download/v$(version)/nghttp2-$(version).tar.gz")
    add_versions("1.68.0", "2c16ffc588ad3f9e2613c3fad72db48ecb5ce15bc362fcc85b342e48daf51013")
    add_versions("1.67.1", "da8d640f55036b1f5c9cd950083248ec956256959dc74584e12c43550d6ec0ef")
    add_versions("1.67.0", "f61f8b38c0582466da9daa1adcba608e1529e483de6b5b2fbe8a5001d41db80c")
    add_versions("1.66.0", "e178687730c207f3a659730096df192b52d3752786c068b8e5ee7aeb8edae05a")
    add_versions("1.65.0", "8ca4f2a77ba7aac20aca3e3517a2c96cfcf7c6b064ab7d4a0809e7e4e9eb9914")
    add_versions("1.64.0", "20e73f3cf9db3f05988996ac8b3a99ed529f4565ca91a49eb0550498e10621e8")
    add_versions("1.63.0", "9318a2cc00238f5dd6546212109fb833f977661321a2087f03034e25444d3dbb")
    add_versions("1.62.1", "d0b0b9d00500ee4aa3bfcac00145d3b1ef372fd301c35bff96cf019c739db1b4")
    add_versions("1.62.0", "482e41a46381d10adbdfdd44c1942ed5fd1a419e0ab6f4a5ff5b61468fe6f00d")
    add_versions("1.61.0", "aa7594c846e56a22fbf3d6e260e472268808d3b49d5e0ed339f589e9cc9d484c")
    add_versions("1.60.0", "ca2333c13d1af451af68de3bd13462de7e9a0868f0273dea3da5bc53ad70b379")
    add_versions("1.59.0", "90fd27685120404544e96a60ed40398a3457102840c38e7215dc6dec8684470f")
    add_versions("1.58.0", "9ebdfbfbca164ef72bdf5fd2a94a4e6dfb54ec39d2ef249aeb750a91ae361dfb")
    add_versions("1.46.0", "4b6d11c85f2638531d1327fe1ed28c1e386144e8841176c04153ed32a4878208")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_load("windows", "mingw", function (package)
        if package:is_plat("windows") then
            package:add("defines", "ssize_t=int")
        end
        if not package:config("shared") then
            package:add("defines", "NGHTTP2_STATICLIB")
        end
    end)

    on_install(function (package)
        io.replace("CMakeLists.txt", "add_subdirectory(doc)", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(tests)", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(examples)", "", {plain = true})

        local configs = {"-DENABLE_LIB_ONLY=ON", "-DENABLE_APP=OFF", "-DENABLE_DOC=OFF", "-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DENABLE_SHARED_LIB=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_STATIC_LIB=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_STATIC_LIBS=" .. (package:config("shared") and "OFF" or "ON"))
        if package:is_plat("windows") then
            table.insert(configs, "-DENABLE_STATIC_CRT=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
            if package:config("shared") then
                table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("nghttp2_version", {includes = "nghttp2/nghttp2.h"}))
    end)
