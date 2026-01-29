package("dispenso")
    set_homepage("https://github.com/facebookincubator/dispenso")
    set_description("The project provides high-performance concurrency, enabling highly parallel computation.")
    set_license("MIT")

    add_urls("https://github.com/facebookincubator/dispenso/archive/refs/tags/$(version).tar.gz",
             "https://github.com/facebookincubator/dispenso.git")

    add_versions("v1.4.1", "e31fecf0e5f434553373bb3fd1b4f4e8503e6ca902f9bed0d4f2d0bb7d2ff280")
    add_versions("v1.4.0", "d1c84ba77d6d3a0da24010a930c81acb4c149532afd8ab352c9cae54c51b6f72")
    add_versions("v1.3.0", "824afe8d0d36bfd9bc9b1cbe9be89e7f3ed642a3612766d1c99d5f8dfc647c63")
    add_versions("v1.2.0", "a44d9cf2f9234f5cbdbe4050fd26e63f3266b64955731651adf04dbb7f6b31df")
    add_versions("v1.1.0", "581f95c16cd479692bc89448d0648f6ce24162454308c544c4d35bf5e9efe5c8")

    add_patches("1.2.0", "patches/1.2.0/namespace.patch", "a0c00cad221f05f9624a28c2e22f6e419b21b9832281cb875283bf89847b50f1")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    elseif is_plat("windows", "mingw") then
        add_defines("NOMINMAX")
        add_syslinks("winmm", "synchronization")
    end

    add_deps("cmake")
    add_deps("concurrentqueue")

    on_install("windows|x64", "linux", "macosx", "bsd", "mingw", "msys", "android", "iphoneos", "cross", "wasm", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DDISPENSO_SHARED_LIB=" .. (package:config("shared") and "ON" or "OFF"))

        io.replace("dispenso/CMakeLists.txt", "-Werror", "", {plain = true})
        io.replace("dispenso/CMakeLists.txt", "/WX", "", {plain = true})
        io.replace("dispenso/CMakeLists.txt", "Synchronization", "Synchronization winmm", {plain = true})
        import("package.tools.cmake").install(package, configs)

        os.tryrm(package:installdir("include/dispenso/third-party"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <dispenso/thread_pool.h>
            void test() {
                dispenso::ThreadPool& threadPool = dispenso::globalThreadPool();
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
