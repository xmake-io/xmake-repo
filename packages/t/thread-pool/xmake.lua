package("thread-pool")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/bshoshany/thread-pool")
    set_description("BS::thread_pool: a fast, lightweight, and easy-to-use C++17 thread pool library")
    set_license("MIT")

    add_urls("https://github.com/bshoshany/thread-pool/archive/refs/tags/$(version).tar.gz",
             "https://github.com/bshoshany/thread-pool.git")

    add_versions("v5.1.0", "54378fb9cbeaee72996d3f8761469c43bb7dd2d4b07faec6d29a68277bd91a51")
    add_versions("v5.0.0", "617a8fbc2c360577f498998f336777c73d581810831d4ce9c920f11ec680b07b")
    add_versions("v4.1.0", "be7abecbc420bb87919eeef729b13ff7c29d5ce547bdae284923296c695415bd")
    add_versions("v3.3.0", "b76c0103c7ed07c137bd5b1988b9c09da280bbbad37588a096d2954c8d996e0f")

    if on_check then
        on_check("bsd", function (package)
            if package:version() and package:version():ge("5.0.0") then
                raise("package(thread-pool) unsupported platform")
            end
        end)
    end

    on_install(function (package)
        if package:version() and package:version():ge("3.5.0") then
            os.vcp("include", package:installdir())
        else
            os.vcp("BS_thread_pool.hpp", package:installdir("include"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                BS::thread_pool pool;
            }
        ]]}, {configs = {languages = "c++17"}, includes = "BS_thread_pool.hpp"}))
    end)
