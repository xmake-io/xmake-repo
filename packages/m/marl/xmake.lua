package("marl")
    set_homepage("https://github.com/google/marl")
    set_description("A hybrid thread / fiber task scheduler written in C++ 11")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/marl.git", {submodules = false})

    add_versions("2025.02.23", "23bbc9bf0017ba75844d5be5b12b15c0134ca276")
    add_versions("2022.03.02", "9929747c9ba6354691dbacaf14f9b35433871e5b")
    add_versions("2021.08.18", "49602432d97222eec1e6c8e4f70723c3864c49c1")

    add_deps("cmake")
    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_install(function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "MARL_DLL=1")
        end

        io.replace("CMakeLists.txt", "POSITION_INDEPENDENT_CODE 1", "", {plain = true})

        local configs = {"-DMARL_INSTALL=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DMARL_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DMARL_ASAN=" .. (package:config("asan") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <marl/scheduler.h>
            void test() {
                marl::Scheduler scheduler(marl::Scheduler::Config::allCores());
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
