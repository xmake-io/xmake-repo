package("marl")

    set_homepage("https://github.com/google/marl")
    set_description("Marl is a hybrid thread / fiber task scheduler written in C++ 11.")

    add_urls("https://github.com/google/marl.git")

    add_versions("2021.8.18", "49602432d97222eec1e6c8e4f70723c3864c49c1")
    add_versions("2022.3.02", "9929747c9ba6354691dbacaf14f9b35433871e5b")

    add_deps("cmake")
    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DMARL_INSTALL=on"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.insert(configs, "-DBUILD_SHARED_LIBS=on")
        else
            table.insert(configs, "-DBUILD_SHARED_LIBS=off")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({
            test = [[
            #include <marl/scheduler.h>
            void test() {
                marl::Scheduler scheduler(marl::Scheduler::Config::allCores());
            }
            ]]},
            {configs = {languages = "c++17"}
        }))
    end)
