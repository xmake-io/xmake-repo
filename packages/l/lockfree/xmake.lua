package("lockfree")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/DNedic/lockfree")
    set_description("A collection of lock-free data structures written in standard C++11")
    set_license("MIT")

    add_urls("https://github.com/DNedic/lockfree/archive/refs/tags/$(version).tar.gz",
             "https://github.com/DNedic/lockfree.git")

    add_versions("2.0.10", "0a810c522f7a0b7d1d2ffad6079cdf552735d3489db1c5ded72b8b369e60e9fb")

    on_install(function (package)
        os.cp("lockfree/**.hpp", package:installdir("include/lockfree"), {rootdir = "lockfree"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                lockfree::spsc::RingBuf<int, 1024> rb_uart;
            }
        ]]}, {configs = {languages = "c++11"}, includes = {"lockfree/lockfree.hpp"}}))
    end)
