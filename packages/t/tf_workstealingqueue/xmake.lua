package("tf_workstealingqueue")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/taskflow/work-stealing-queue")
    set_description("A fast work-stealing queue template in C++")
    set_license("MIT")

    add_urls("https://github.com/taskflow/work-stealing-queue.git")
    add_versions("2022.07.20", "378e297749374300bf9bc0229096285447993877")

    on_install(function (package)
        os.cp("wsq.hpp", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            static void test() {
                WorkStealingQueue<int> queue;
                queue.push(0);
                queue.push(1);

                std::optional<int> item1 = queue.pop();
                std::optional<int> item2 = queue.steal();
            }
        ]]}, {configs = {languages = "c++17"}, includes = {"wsq.hpp"}}))
    end)

