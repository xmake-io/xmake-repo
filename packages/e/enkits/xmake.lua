package("enkits")

    set_homepage("https://github.com/dougbinks/enkiTS")
    set_description("A permissively licensed C and C++ Task Scheduler for creating parallel programs.")
    set_license("zlib")

    add_urls("https://github.com/dougbinks/enkiTS/archive/refs/tags/$(version).tar.gz",
             "https://github.com/dougbinks/enkiTS.git")
    add_versions("v1.10", "578f285fc7c2744bf831548f35b855c6ab06c0d541d08c9cc50b6b72a250811a")

    add_deps("cmake")
    add_linkdirs("lib/enkiTS")
    add_links("enkiTS")
    if is_plat("linux") then
        add_syslinks("pthread", "rt")
    end
    on_load("windows", function (package)
        if package:config("shared") then
            package:add("defines", "ENKITS_DLL")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DENKITS_BUILD_EXAMPLES=OFF", "-DENKITS_INSTALL=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DENKITS_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets([[
            void test() {
                enki::TaskScheduler g_TS;
                g_TS.Initialize();
            }
        ]], {configs = {languages = "c++17"}, includes = "enkiTS/TaskScheduler.h"}))
    end)
