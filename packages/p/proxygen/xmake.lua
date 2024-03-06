package("proxygen")
    set_homepage("https://github.com/facebook/proxygen")
    set_description("A collection of C++ HTTP libraries including an easy to use HTTP server.")
    set_license("BSD")

    add_urls("https://github.com/facebook/proxygen/archive/refs/tags/v$(version).00.tar.gz",
             "https://github.com/facebook/proxygen.git")
    add_versions("2024.03.04", "c3586cd8a3978dd88ea73b7dc217b0ce9f3bae51f5a2e554135daaf772215e8d")

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
