package("taskflow")
    set_kind("library", {headeronly = true})
    set_homepage("https://taskflow.github.io/")
    set_description("A fast C++ header-only library to help you quickly write parallel programs with complex task dependencies")
    set_license("MIT")

    add_urls("https://github.com/taskflow/taskflow.git")
    add_urls("https://github.com/taskflow/taskflow/archive/refs/tags/$(version).tar.gz")

    add_versions("v4.0.0", "6b050b0db6b6fb4c72c7c65cf6b468b2551adffe708a9a63ade0f3c1ae7d7e2a")
    add_versions("v3.11.0", "5e45a7ee032cae136843c76824519acbc0306f02d682f7e69fb1d53f69173dcb")
    add_versions("v3.10.0", "fe86765da417f6ceaa2d232ffac70c9afaeb3dc0816337d39a7c93e39c2dee0b")
    add_versions("v3.9.0", "d872a19843d12d437eba9b8664835b7537b92fe01fdb33ed92ca052d2483be2d")
    add_versions("v3.8.0", "51316ee5fbf0c8f8f4638eb7428430cadfe6e8910756593884710e99129fa0ab")
    add_versions("v3.7.0", "788b88093fb3788329ebbf7c7ee05d1f8960d974985a301798df01e77e04233b")
    add_versions("v3.6.0", "5a1cd9cf89f93a97fcace58fd73ed2fc8ee2053bcb43e047acb6bc121c3edf4c")
    add_versions("v3.5.0", "33c44e0da7dfda694d2b431724d6c8fd25a889ad0afbb4a32e8da82e2e9c2a92")
    add_versions("v3.4.0", "8f449137d3f642b43e905aeacdf1d7c5365037d5e1586103ed4f459f87cecf89")
    add_versions("v3.3.0", "66b891f706ba99a5ca5ed239d520ad6943ebe94728d1c89e07a939615a6488ef")
    add_versions("v3.2.0", "26c37a494789fedc5de8d1f8452dc8a7774a220d02c14d5b19efe0dfe0359c0c")
    add_versions("v3.1.0", "17b56e23312d20c4ad5cc497b9f42cd0ad4451dbd2df0160a0a692fd16d47143")
    add_versions("v3.0.0", "553c88a6e56e115d29ac1520b8a0fea4557a5fcda1af1427bd3ba454926d03a2")

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    if on_check then
        on_check("android", function (package)
            if package:version() and package:version():ge("3.11.0") then
                local ndk = package:toolchain("ndk"):config("ndkver")
                assert(ndk and tonumber(ndk) >= 26, "package(taskflow >=3.11.0) requires ndk version >= 26")
            end
        end)
    end

    on_install("linux", "macosx", "windows", "iphoneos", "android", "cross", "mingw", "bsd", function (package)
        os.cp("taskflow", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <taskflow/taskflow.hpp>
            #include <taskflow/algorithm/for_each.hpp>
            static void test() {
                tf::Executor executor;
                tf::Taskflow taskflow;
                std::vector<int> range(10);
                std::iota(range.begin(), range.end(), 0);
                taskflow.for_each(range.begin(), range.end(), [&] (int i) {
                    printf("for_each on container item: %d\n", i);
                });
                executor.run(taskflow).wait();
            }
        ]]}, {configs = {languages = package:version():ge("4.0.0") and "c++20" or "c++17"}}))
    end)
