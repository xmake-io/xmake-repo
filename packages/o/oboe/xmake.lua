package("oboe")
    set_homepage("https://github.com/google/oboe")
    set_description("Oboe is a C++ library that makes it easy to build high-performance audio apps on Android.")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/oboe/archive/refs/tags/$(version).tar.gz",
             "https://github.com/google/oboe.git")

    add_versions("1.9.3", "9d2486b74bd396d9d9112625077d5eb656fd6942392dc25ebf222b184ff4eb61")

    add_deps("cmake")

    on_install("android", function (package)
        io.replace("CMakeLists.txt", "LIBRARY DESTINATION lib/${ANDROID_ABI}", "LIBRARY DESTINATION lib", {plain = true})
        io.replace("CMakeLists.txt", "ARCHIVE DESTINATION lib/${ANDROID_ABI}", "ARCHIVE DESTINATION lib", {plain = true})
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                oboe::FifoBuffer * buf = new oboe::FifoBuffer(4, 10240);
                auto bytes = buf->convertFramesToBytes(32);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "oboe/Oboe.h"}))
    end)
