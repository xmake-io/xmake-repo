package("atomic_queue")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/max0x7ba/atomic_queue")
    set_description("C++ lockless queue.")
    set_license("MIT")

    add_urls("https://github.com/max0x7ba/atomic_queue/archive/refs/tags/$(version).tar.gz",
             "https://github.com/max0x7ba/atomic_queue.git")
    add_versions("v1.5", "599b76a0222e7b54118d6f0fb686845c9d323107f2de76b3f68292b057e5a99f")

    on_install(function (package)
        os.cp("include/atomic_queue/", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            int test(int argc, char* argv[]) {
                using Queue = atomic_queue::AtomicQueue<uint32_t, 1024>;
                Queue q{};
                q.try_push(10);
                return 0;
            }
        ]]}, {configs = {languages = "cxx14"}, includes = "atomic_queue/atomic_queue.h"}))
    end)
