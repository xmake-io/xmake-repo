package("citor")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Lallapallooza/citor")
    set_description("Header-only C++20 thread pool with sub-microsecond dispatch, decentralized work-stealing, and per-CCD arenas.")
    set_license("MIT")
    add_urls("https://github.com/Lallapallooza/citor.git")
    add_versions("v0.6.1","717f59a3e443858973d1e143d0cfeb061ba0dd5d")
    add_versions("v0.6.0","ffc33c285f22d2a0d7dc5feb4662c08fe06b537f")
    add_versions("v0.5.0","77bd994439b2500d7691e75ab1132a27f9eb4d8b")
    on_install("!windows|arm64", "!*|i386", "!*|i686", "!*|arm",function (package)
        os.cp("include/*", package:installdir("include"))
    end)
    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <citor/coro.h>
            citor::coro::Task<std::int64_t> work(citor::ThreadPool &pool) {
                co_return co_await citor::coro::parallelReduce(pool, 0, 100, std::int64_t{0});
            }
            void test() {
                citor::ThreadPool pool(4);
                (void)citor::coro::syncWait(work(pool));
            }
        ]]}, {configs = {languages = "c++23"}, includes = "citor/coro.h"}))
    end)