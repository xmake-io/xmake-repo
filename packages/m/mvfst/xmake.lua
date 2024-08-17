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
    add_versions("2024.06.10", "cc75889429a66463cc8e607ba09d584fb4e6d2e69b1127a538043b367c54a1ae")
    add_versions("2024.06.17", "748c744dae967a0ac25c89a6c7ccf62da2a4974ab45644d395fb7bc8f2e96dc1")
    add_versions("2024.06.24", "0a8c9bf9c9e1e293e56c0bd05e60606b2b299245510442a2e9af01519c040041")
    add_versions("2024.07.01", "833fc3421cb8a17ab1c2b5542e76074bcb9cfd534ec5e459393dd1e774921907")
    add_versions("2024.07.08", "345080326a3a8a24439253f7029b8f3c0785d804a179757b94ea2a5a52f4013f")
    add_versions("2024.07.15", "598ac31d018c980c60d19fd5bd625b79cc6235250fdb3210524cfaa6cf27bddb")

    add_patches(">=2024.06.17", path.join(os.scriptdir(), "patches", "shared.patch"), "6b940f5a07e476d1f13b7d427923573333c82eb3b887d25927b6da9b0400c107")

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
        assert(package:has_cxxfuncs("quic::isClientStream(0)", {includes = "quic/state/QuicStreamUtilities.h", configs = {languages = "c++17"}}))
    end)
