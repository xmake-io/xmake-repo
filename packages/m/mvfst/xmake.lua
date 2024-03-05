package("mvfst")
    set_homepage("https://github.com/facebook/mvfst")
    set_description("An implementation of the QUIC transport protocol.")
    set_license("MIT")

    add_urls("https://github.com/facebook/mvfst/archive/refs/tags/v$(version).00.tar.gz",
             "https://github.com/facebook/mvfst.git")
    add_versions("2024.03.04", "06922633d6ee2f01e77f66812c87517ebbf06bbb56552a61ba1f7a3b757dc15a")

    add_deps("cmake", "folly", "fizz")

    on_install("linux", function (package)
        local configs = {"-DBUILD_TESTS=OFF",
                         "-DBUILD_EXAMPLES=OFF",
                         "-DCMAKE_CXX_STANDARD=17"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("quic/QuicConstants.h", {configs = {languages = "c++17"}}))
    end)
