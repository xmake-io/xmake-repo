package("nndeploy")
    set_homepage("https://github.com/nndeploy/nndeploy")
    set_description("nndeploy是一款模型端到端部署框架。以多端推理以及基于有向无环图模型部署为基础，致力为用户提供跨平台、简单易用、高性能的模型部署体验。")
    set_license("Apache-2.0")

    set_urls("https://github.com/nndeploy/nndeploy/archive/refs/tags/$(version).tar.gz", {version = function (version)
        return version:gsub("%+", ".")
    end})
    
    add_versions("1.0.0+0", "02d38313eec77de4c028803255be284b13bc9bc8dd775ee5147f7f98ff7831eb")

    add_configs("demo", {description = "Enable demo.", default = false, type = "boolean"})

    add_deps("cmake","ninja")

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_install("macosx", "linux", "windows", function (package)
        local options = {
            demo = "ENABLE_NNDEPLOY_DEMO",
        }
        os.mkdir("build")
        os.cp("cmake/config.cmake", "build")

        io.replace("CMakeLists.txt", "NNDEPLOY_INSTALL_PATH ${ROOT_PATH}/build/install", "NNDEPLOY_INSTALL_PATH " .. package:installdir():gsub("\\", "/"), {plain = true})

        if not package:config("shared") then
            io.replace("build/config.cmake", "ENABLE_NNDEPLOY_BUILD_SHARED ON", "ENABLE_NNDEPLOY_BUILD_SHARED OFF", {plain = true})
        end

        for name, item in pairs(options) do
            if package:config(name) then
                io.replace("build/config.cmake", item .. " OFF", item .. " ON", {plain = true})
            else
                io.replace("build/config.cmake", item .. " ON", item .. " OFF", {plain = true})
            end
        end

        local configs = { }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))

        import("package.tools.cmake").install(package, configs, {cmake_generator = "Ninja", buildir = "build"})

        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                using namespace nndeploy;
                dag::Edge graph_in("graph_in");
                dag::Edge graph_out("graph_out");
                dag::Graph *graph = new dag::Graph("serial_graph", &graph_in, &graph_out);
            }
        ]]}, {configs = {languages = "c++11"}, includes = {"nndeploy/dag/graph.h"}}))
    end)
