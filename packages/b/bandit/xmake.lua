package("bandit")
    set_kind("library", {headeronly = true})
    set_homepage("https://banditcpp.github.io/bandit/")
    set_description("Human-friendly unit testing for C++11")

    add_urls("https://github.com/banditcpp/bandit.git", {submodules = false})

    add_versions("2023.08.05", "f297efd8aecc6e9ce8f84e33264898bf77f9cb73")
    add_patches("2023.08.05", "patches/2023.08.05/debundle-snowhouse.patch", "66d5f6beb2a2f099b7e22ed6b7993f70ee01630e0df10f149c4d0e792b3a42a0")

    add_deps("snowhouse")

    on_install(function (package)
        os.cp("bandit", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <bandit/bandit.h>
            using namespace bandit;
            go_bandit([](){
                AssertThat(123, snowhouse::Equals(123));
            });
            void test() {
                int argc;
                char* argv[2];
                bandit::run(argc, argv);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
