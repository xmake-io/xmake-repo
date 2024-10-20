package("ngtcp2")
    set_homepage("https://github.com/ngtcp2/ngtcp2")
    set_description("ngtcp2 project is an effort to implement IETF QUIC protocol")
    set_license("MIT")

    add_urls("https://github.com/ngtcp2/ngtcp2/releases/download/v$(version)/ngtcp2-$(version).tar.gz")
    add_versions("1.8.1", "72b544d2509b8fb58c493f9d3d71fe93959f94bca48aa0c87ddd56bf61178cee")
    add_versions("1.8.0", "f39ca500b10c432204dda5621307e29bdbdf26611fabbc90b1718f9f39eb3203")
    add_versions("1.7.0", "59dccb5c9a615eaf9de3e3cc3299134c22a88513b865b78a3e91d873c08a0664")
    add_versions("1.6.0", "0c6f140268ef80a86b146714f7dc7c03a94699d019cd1815870ba222cb112bf0")
    add_versions("1.5.0", "fbd9c40848c235736377ba3fd0b8677a05d39e7c39406769588a6595dda5636f")
    add_versions("1.4.0", "163e26e6e7531b8bbcd7ec53d2c6b4ff3cb7d3654fde37b091e3174d37a8acd7")
    add_versions("1.3.0", "7d4244ac15a83a0f908ff810ba90a3fcd8352fb0020a6f9176e26507c9d3c3e4")
    add_versions("1.2.0", "303ae7d23721b3631ae52dbe3e05cced9ac59aa49d3eb21f8cdb1548a0522be8")
    add_versions("1.1.0", "051d23ce0128453687c240e6fa249e65134350b2b1cb1b5eadf49817849ec74d")
    add_versions("0.1.0", "9a5266544d083c332746450344ebd6c8d6bf3c75c492a54c79abc56f2c47415d")

    add_deps("cmake")

    on_install("macosx", "linux", "windows", "android", "mingw", function (package)
        local configs = {"-DENABLE_OPENSSL=OFF", "-DBUILD_TESTING=OFF"}
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
