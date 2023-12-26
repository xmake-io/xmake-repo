package("dispenso")
    set_homepage("https://github.com/facebookincubator/dispenso")
    set_description("The project provides high-performance concurrency, enabling highly parallel computation.")
    set_license("MIT")

    add_urls("https://github.com/facebookincubator/dispenso/archive/refs/tags/$(version).tar.gz",
             "https://github.com/facebookincubator/dispenso.git")

    add_versions("v1.1.0", "581f95c16cd479692bc89448d0648f6ce24162454308c544c4d35bf5e9efe5c8")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    elseif is_plat("windows") then
        add_defines("NOMINMAX")
        add_syslinks("winmm", "synchronization")
    end

    add_deps("cmake")
    add_deps("concurrentqueue")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DDISPENSO_SHARED_LIB=" .. (package:config("shared") and "ON" or "OFF"))
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
