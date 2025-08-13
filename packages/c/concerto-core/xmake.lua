package("concerto-core")
    set_homepage("https://github.com/ConcertoEngine/ConcertoCore")
    set_description("Concerto engine core library")
    set_license("MIT")

    add_urls("https://github.com/ConcertoEngine/ConcertoCore.git")

    add_versions("2025.08.13", "7df6b6653034bcde839cc212c7c91057e534a123")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean"})
    add_configs("asserts", {description = "Enable asserts.", default = false, type = "boolean"})
    add_configs("enet", {description = "Enable ENet support.", default = false, type = "boolean"})

    on_load(function (package)
        if package:config("enet") then
            package:add("deps", "enet")
        end
    end)

    on_install(function (package)
        if package:has_tool("cxx", "cl", "clang_cl") then
            package:add("cxxflags", "/Zc:preprocessor")
        end
        if not package:config("shared") then
            package:add("defines", "CCT_CORE_LIB_STATIC")
        end

        local configs = {}
        configs.static = not package:config("shared")
        configs.tests = false
        configs.mode = package:is_debug() and "debug" or "release"
        configs.override_runtime = false
        configs.asserts = package:config("asserts")
        configs.enet = package:config("enet")

        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <string>
            #include <Concerto/Core/Types.hpp>
            #include <Concerto/Core/Result.hpp>
            #include <Concerto/Core/DynLib.hpp>
            void test() {
                cct::Result<cct::Int32, std::string> result(28);
                cct::DynLib lib;
                bool ok = lib.IsLoaded();
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
