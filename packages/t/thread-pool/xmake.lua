package("thread-pool")
	set_kind("library", {headeronly = true})
    set_homepage("https://github.com/bshoshany/thread-pool")
    set_description("BS::thread_pool: a fast, lightweight, and easy-to-use C++17 thread pool library")
    set_license("MIT")

    add_urls("https://github.com/bshoshany/thread-pool/archive/refs/tags/$(version).tar.gz",
             "https://github.com/bshoshany/thread-pool.git")
    add_versions("v3.3.0", "b76c0103c7ed07c137bd5b1988b9c09da280bbbad37588a096d2954c8d996e0f")

    on_install(function (package)
        os.cp("BS_thread_pool.hpp", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({
			test = [[
				#include <BS_thread_pool.hpp>
				static void test() {
					BS::thread_pool pool;
					std::future<int> my_future = pool.submit([] { return 42; });
					std::cout << my_future.get();
				}
			]]
		}, {configs = {languages = "c++17"}, includes = {"BS_thread_pool.hpp"}}))
    end)
