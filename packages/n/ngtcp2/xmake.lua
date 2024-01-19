package("ngtcp2")
    set_homepage("https://github.com/ngtcp2/ngtcp2")
    set_description("ngtcp2 project is an effort to implement IETF QUIC protocol")
    set_license("MIT")

    add_urls("https://github.com/ngtcp2/ngtcp2/releases/download/v$(version)/ngtcp2-$(version).tar.gz")
    add_versions("1.1.0", "051d23ce0128453687c240e6fa249e65134350b2b1cb1b5eadf49817849ec74d")
    add_versions("0.1.0", "9a5266544d083c332746450344ebd6c8d6bf3c75c492a54c79abc56f2c47415d")

    add_deps("cmake")

    on_install("macosx", "linux", "windows", "android", "mingw", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DENABLE_SHARED_LIB=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_STATIC_LIB=" .. (package:config("shared") and "OFF" or "ON"))
        io.replace("CMakeLists.txt", "add_subdirectory(third-party)", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(examples)", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(tests)", "", {plain = true})
        if not package:config("shared") then
            package:add("defines", "NGTCP2_STATICLIB")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ngtcp2_conn_client_new_versioned", {includes = "ngtcp2/ngtcp2.h"}))
    end)
