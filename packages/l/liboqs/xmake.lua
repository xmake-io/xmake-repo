package("liboqs")
    set_homepage("https://openquantumsafe.org")
    set_description("C library for prototyping and experimenting with quantum-resistant cryptography")

    add_urls("https://github.com/open-quantum-safe/liboqs/archive/refs/tags/$(version).tar.gz",
             "https://github.com/open-quantum-safe/liboqs.git")

    add_versions("0.10.1", "00ca8aba65cd8c8eac00ddf978f4cac9dd23bb039f357448b60b7e3eed8f02da")

    add_deps("cmake")

    on_install("linux", "macosx", function (package)
        local configs = {"-DOQS_BUILD_ONLY_LIB=ON", "-DOQS_USE_OPENSSL=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("OQS_SIG_keypair", {includes = "oqs/oqs.h"}))
    end)
