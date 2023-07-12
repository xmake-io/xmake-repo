package("wavpack")
    set_homepage("https://github.com/dbry/WavPack")
    set_description("WavPack encode/decode library, command-line programs, and several plugins")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/dbry/WavPack//archive/refs/tags/$(version).tar.gz",
             "https://github.com/dbry/WavPack.git")

    add_versions("4.80.0", "c72cb0bbe6490b84881d61f326611487eedb570d8d2e74f073359578b08322e2")
    add_versions("5.4.0",  "abbe5ca3fc918fdd64ef216200a5c896243ea803a059a0662cd362d0fa827cd2")
    add_versions("5.5.0",  "b3d11ba35d12c7d2ed143036478b6f9f4bdac993d84b5ed92615bc6b60697b8a")
    add_versions("5.6.0",  "44043e8ffe415548d5723e9f4fc6bda5e1f429189491c5fb3df08b8dcf28df72")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("WavpackOpenRawDecoder", {includes = "wavpack/wavpack.h"}))
    end)
