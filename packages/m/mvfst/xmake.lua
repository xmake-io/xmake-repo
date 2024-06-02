package("mvfst")
    set_homepage("https://github.com/facebook/mvfst")
    set_description("An implementation of the QUIC transport protocol.")
    set_license("MIT")

    add_urls("https://github.com/facebook/mvfst/archive/refs/tags/v$(version).00.tar.gz",
             "https://github.com/facebook/mvfst.git")
    add_versions("2024.03.04", "06922633d6ee2f01e77f66812c87517ebbf06bbb56552a61ba1f7a3b757dc15a")
    add_versions("2024.03.11", "4ba28efd162f83c7a330fab811f128490a787ef91d6366c6df9fc1f70e9b423d")
    add_versions("2024.03.18", "7f42ad4b8da5646a24ba5e96101da914f77fe581abd686568d1dcd6492df0240")
    add_versions("2024.03.25", "293046511fb9395bdb09860f4c4202bcb848fed4cdd419d436506a07eeac66cd")
    add_versions("2024.04.01", "e39c4d7dd87520fcce6a3d5d398b5d03bd3e680186b9b0db23f02b502c6bcb1e")

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
