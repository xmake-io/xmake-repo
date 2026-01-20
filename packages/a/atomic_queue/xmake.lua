package("atomic_queue")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/max0x7ba/atomic_queue")
    set_description("C++ lockless queue.")
    set_license("MIT")

    add_urls("https://github.com/max0x7ba/atomic_queue/archive/refs/tags/$(version).tar.gz",
             "https://github.com/max0x7ba/atomic_queue.git")
    add_versions("v1.7.1", "6eeff578f8b0499717bf890d90e2c58106ac2b8076084b73f2183a631742b4ab")
    add_versions("v1.6.9", "6d2fc922c3e0325c9ab000832d59a860ae3b6f7f319b645148455c4bef7b52a9")
    add_versions("v1.6.5", "0257efe6781637091ff7f11d836cff4a8e0b5ea22c943fa70e00e83d83360583")
    add_versions("v1.6.4", "e9c3ae4b850dc6503ee484748701f06f3737ad177c5cb31030f74e3fef40e282")
    add_versions("v1.5", "599b76a0222e7b54118d6f0fb686845c9d323107f2de76b3f68292b057e5a99f")
    add_versions("v1.6.3", "0ad6e0203d90367f6a4e496449dfd9ad65b80168fadafef4eac08820c6bda79c")

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
