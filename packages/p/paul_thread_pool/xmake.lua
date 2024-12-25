package("paul_thread_pool")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/DeveloperPaul123/thread-pool")
    set_description("A modern, fast, lightweight thread pool library based on C++20")
    set_license("MIT")

    add_urls("https://github.com/DeveloperPaul123/thread-pool/archive/refs/tags/$(version).zip",
             "https://github.com/DeveloperPaul123/thread-pool.git")

    add_versions("0.6.2", "a2b722560449da53faf4753288a5fb2074d88b1fa9bba257c85425b3e48ecb2c")

    on_check(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <thread>
            void test() {
                std::jthread t;
            }
        ]]}, {configs = {languages = "c++20"}}), "package(paul_thread_pool) require c++20 jthread")
    end)

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <thread>
            #include <thread_pool/thread_pool.h>

            void test()
            {
                dp::thread_pool pool;
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
