package("nghttp2")

    set_homepage("http://nghttp2.org/")
    set_description("nghttp2 is an implementation of HTTP/2 and its header compression algorithm HPACK in C.")
    set_license("MIT")

    add_urls("https://github.com/nghttp2/nghttp2/releases/download/v$(version)/nghttp2-$(version).tar.gz")
    add_versions("1.58.0", "9ebdfbfbca164ef72bdf5fd2a94a4e6dfb54ec39d2ef249aeb750a91ae361dfb")
    add_versions("1.46.0", "4b6d11c85f2638531d1327fe1ed28c1e386144e8841176c04153ed32a4878208")

    add_deps("cmake")
    on_load("windows", function (package)
        package:add("defines", "ssize_t=int")
        if not package:config("shared") then
            package:add("defines", "NGHTTP2_STATICLIB")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        io.replace("CMakeLists.txt", "add_subdirectory(doc)", "", {plain = true})
        local configs = {"-DENABLE_LIB_ONLY=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DENABLE_SHARED_LIB=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_STATIC_LIB=" .. (package:config("shared") and "OFF" or "ON"))
        if package:is_plat("windows") then
            table.insert(configs, "-DENABLE_STATIC_CRT=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("nghttp2_version", {includes = "nghttp2/nghttp2.h"}))
    end)
