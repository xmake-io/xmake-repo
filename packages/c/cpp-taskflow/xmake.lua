package("cpp-taskflow")

    set_homepage("https://cpp-taskflow.github.io/")
    set_description("A fast C++ header-only library to help you quickly write parallel programs with complex task dependencies")

    add_urls("https://github.com/cpp-taskflow/cpp-taskflow.git")
    add_urls("https://github.com/cpp-taskflow/cpp-taskflow/archive/v$(version).zip")
    add_versions("2.2.0", "6b3c3b083e6e93a988cebc8bbf794a78f61904efab21f1e3a667b3cf60d58ca2")

    on_install(function (package)
        os.cp("taskflow", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <assert.h>
            static void test() {
                tf::Executor executor;
                tf::Taskflow taskflow;
                std::vector<int> range(10);
                std::vector<int> out(10);
                std::iota(range.begin(), range.end(), 0);
                std::iota(out.begin(), out.end(), 0);
                taskflow.parallel_for(range.begin(), range.end(), [&] (const int i) { 
                    out[i] = i;
                });
                executor.run(taskflow).get();
                for (int i = 0; i < 10; i++) {
                    assert(out[i] == i);
                }
            }
        ]]}, {configs = {languages = "c++1z"}, includes = "taskflow/taskflow.hpp"}))
    end)    
    
