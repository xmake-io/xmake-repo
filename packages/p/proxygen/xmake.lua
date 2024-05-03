package("proxygen")
    set_homepage("https://github.com/facebook/proxygen")
    set_description("A collection of C++ HTTP libraries including an easy to use HTTP server.")
    set_license("BSD")

    add_urls("https://github.com/facebook/proxygen/archive/refs/tags/v$(version).00.tar.gz",
             "https://github.com/facebook/proxygen.git")
    add_versions("2024.03.04", "c3586cd8a3978dd88ea73b7dc217b0ce9f3bae51f5a2e554135daaf772215e8d")
    add_versions("2024.03.11", "39d357650d1fdfb3b34c17eb21ccd8e709fb6c2a391ddfc37bb0c5476a111210")
    add_versions("2024.03.18", "7731c5eea71f1ab3182a1a54329abae983ac63794f86768762a0136587dfd979")
    add_versions("2024.03.25", "b11c8da4dbcbbdde8d9504f2edd3eb537bdf959eccc07a8333d1936965437abc")
    add_versions("2024.04.01", "75b040c235fee853e8db90075620f56ee4aa69345eea9ab4f80aa35501fe2eff")

    add_deps("cmake", "folly", "fizz", "wangle", "mvfst", "gperf", "python")

    on_install("linux", function (package)
        local configs = {"-DBUILD_TESTS=OFF",
                         "-DBUILD_EXAMPLES=OFF",
                         "-DCMAKE_CXX_STANDARD=17"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("proxygen/httpserver/ScopedHTTPServer.h", {configs = {languages = "c++17"}}))
    end)
