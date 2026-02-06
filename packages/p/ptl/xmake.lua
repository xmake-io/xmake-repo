package("ptl")

    set_homepage("https://github.com/jrmadsen/PTL")
    set_description("Lightweight C++11 multithreading tasking system featuring thread-pool, task-groups, and lock-free task queue")
    set_license("MIT")

    add_urls("https://github.com/jrmadsen/PTL/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jrmadsen/PTL.git")
    add_versions("v2.3.3", "3275ad8ec2971c89aacb3b922717dc4e774fa4e59fc3f4035053225c802aee52")
    add_versions("v2.0.0", "58e561a3a1de75679faf4d8760d2ff045ced232d4367157b5b4e4f26c8474721")

    add_configs("tbb", {description = "Enable TBB support.", default = false, type = "boolean"})

    add_deps("cmake")
    if is_plat("linux") then
        add_syslinks("pthread")
    end
    on_load("windows", "macosx", "linux", function (package)
        if package:config("tbb") then
            package:add("deps", "tbb")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        io.replace("cmake/Templates/PTLConfig.cmake.in", "if(WIN32)", "if(FALSE)", {plain = true})
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_STATIC_LIBS=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DPTL_USE_TBB=" .. (package:config("tbb") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <PTL/ThreadPool.hh>
            #include <PTL/TaskGroup.hh>
            void test() {
                PTL::ThreadPool tp(4);
                auto join = [](long& lhs, long rhs) { return lhs += rhs; };
                PTL::TaskGroup<long> foo(join, &tp);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
