package("concurrentqueue")

    set_homepage("https://github.com/cameron314/concurrentqueue")
    set_description("An industrial-strength lock-free queue for C++.")
 
    add_urls("https://github.com/cameron314/concurrentqueue.git")
 
    on_install(function (package)
        os.cp("*.h", package:installdir("include/concurrentqueue"))
    end)
    
    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <assert.h>
            static void test() {
                moodycamel::ConcurrentQueue<int> q;
                bool success = q.enqueue(25);
                int item;
                bool found = q.try_dequeue(item);
                assert(found && item == 25);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "concurrentqueue/concurrentqueue.h"}))
    end)    

