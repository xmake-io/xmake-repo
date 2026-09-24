package("citor")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Lallapallooza/citor")
    set_description("Header-only C++20 thread pool with sub-microsecond dispatch, decentralized work-stealing, and per-CCD arenas.")
    set_license("MIT")

    add_urls("https://github.com/Lallapallooza/citor/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Lallapallooza/citor.git")

    add_versions("v0.6.1", "1a0f930881d064dbc0bde7d605b9c9ef970e07709dc95cdad858a1d6013fc39e")
    add_versions("v0.6.0", "db080e18e10f920d3e4097c031f2c2b152b1a784e300a8439d0dda09221b7829")
    add_versions("v0.5.0", "9a80af1eaf655066fabbe131bf5815a024efc7ea1d728f57243d2a6850fb854d")

    on_install("!*|arm64", "!*|i386", "!*|i686", "!*|arm", function (package)
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
