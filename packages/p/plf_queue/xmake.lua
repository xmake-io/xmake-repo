package("plf_queue")
    set_kind("library", {headeronly = true})
    set_homepage("https://plflib.org/queue.htm")
    set_description("A data container replicating std::queue functionality but with better performance than standard library containers in a queue context.")
    set_license("zlib")

    add_urls("https://github.com/mattreecebentley/plf_queue.git")
    add_versions("v2.0.3", "9d3eeb0822c815388b9df06065010fa48c0a042c")

    on_install(function (package)
        os.cp("plf_queue.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <plf_queue.h>
            void test() {
                plf::queue<int> i_queue;
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
