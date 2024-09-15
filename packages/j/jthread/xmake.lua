package("jthread")
    set_homepage("https://github.com/j0r1/JThread")
    set_description("The JThread package provides some classes to make use of threads easy on different platforms")
    set_license("MIT")

    add_urls("https://github.com/j0r1/JThread.git")

    add_versions("2023.08.18", "719413043807b77448df3ba1c749798fb72ee459")
    add_deps("cmake")

    add_patches("1.3.3", "patches/1.3.3/cmakelist.patch", "4c5162f128f31ebee63805db1dbed0a17fc02b2661958b80468fcffc394d7f4e")

    add_includedirs("include", "include/jthread")
    
    on_install("windows", "linux", "macosx", function(package)

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        if package:config("shared") then 
            table.insert(configs, "-DJTHREAD_COMPILE_STATIC=OFF")
            table.insert(configs, "-DJTHREAD_COMPILE_STATIC_ONLY=OFF")
        else 
            table.insert(configs, "-DJTHREAD_COMPILE_STATIC_ONLY=ON")
            table.insert(configs, "-DJTHREAD_COMPILE_STATIC=ON")
        end

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using namespace jthread;
            class TestThread : public JThread{
            };
        ]]}, {configs = {languages = "c++11"}, includes = "jthread.h"}))
    end)
