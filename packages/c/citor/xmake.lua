package("citor")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Lallapallooza/citor")
    set_description("Header-only C++20 thread pool with sub-microsecond dispatch, decentralized work-stealing, and per-CCD arenas.")
    set_license("MIT")
    add_urls("https://github.com/Lallapallooza/citor.git")
    add_versions("v0.6.1","717f59a3e443858973d1e143d0cfeb061ba0dd5d")
    add_versions("v0.6.0","ffc33c285f22d2a0d7dc5feb4662c08fe06b537f")
    add_versions("v0.5.0","77bd994439b2500d7691e75ab1132a27f9eb4d8b")
    on_install(function (package)
        os.cp("include/citor", package:installdir("include"))
    end)
    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            citor::coro::Task<std::int64_t> work(citor::ThreadPool &pool) {
                co_await citor::coro::parallelFor(pool, 0, n,
                [&](std::size_t lo, std::size_t hi) { /* ... */ });
                std::int64_t sum = co_await citor::coro::parallelReduce(pool, 0, n,
                    std::int64_t{0}, map, combine);
                co_return sum;
            }

            int main(){
                std::int64_t result = citor::coro::syncWait(work(pool));
            }
        ]]}, {configs = {languages = "c++23"}, includes = "citor/coro.h"}))
    end)