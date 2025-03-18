package("gelldur-eventbus")
    set_homepage("https://github.com/gelldur/EventBus")
    set_description("A lightweight and very fast event bus / event framework for C++17 ")
    set_license("Apache-2.0")

    add_urls("https://github.com/gelldur/EventBus/archive/refs/tags/$(version).tar.gz",
             "https://github.com/gelldur/EventBus.git")

    add_versions("v3.1.2", "38e7fb003e875f5bddafd84c478f358007eff7224fafbf2143f9d27dad98e404")

    add_deps("cmake")

    on_install(function (package)
        io.replace("CMakeLists.txt", "add_subdirectory(use_case)", "", {plain = true})
        local configs = {"-DENABLE_TEST=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <memory>
            #include <dexode/EventBus.hpp>
            using EventBus = dexode::EventBus;
            void test() {
                auto eventBus = std::make_shared<EventBus>();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
