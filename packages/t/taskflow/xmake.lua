package("taskflow")

    set_homepage("https://taskflow.github.io/")
    set_description("A fast C++ header-only library to help you quickly write parallel programs with complex task dependencies")

    add_urls("https://github.com/taskflow/taskflow.git")
    add_urls("https://github.com/taskflow/taskflow/archive/$(version).tar.gz")
    add_versions("v2.2.0", "a8ad8c94ceeac0bc18d8429f877e10a2af2cd44cd9dc420d9751e69f48ff85d1")
    add_versions("v3.0.0", "553c88a6e56e115d29ac1520b8a0fea4557a5fcda1af1427bd3ba454926d03a2")

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

