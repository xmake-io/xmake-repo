package("bvh")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/madmann91/bvh")
    set_description("A modern C++ BVH construction and traversal library")
    set_license("MIT")

    add_urls("https://github.com/madmann91/bvh.git")
    add_versions("2023.6.30", "578b1e8035743d0a97fcac802de81622c54f28e3")

    on_install(function (package)
        if not package:is_plat("cross") then
            package:add("cxxflags", "-march=native")
        end
        os.cp("src/bvh", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <bvh/v2/thread_pool.h>
            void test() {
                bvh::v2::ThreadPool thread_pool;
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
