package("manifold")
    set_homepage("https://github.com/elalish/manifold")
    set_description("A Geometry library for topological robustness")

    set_urls("https://github.com/elalish/manifold/releases/download/v$(version)/manifold-$(version).tar.gz","https://github.com/elalish/manifold.git")

    add_versions("3.2.1", "67c4e0cb836f9d6dfcb7169e9d19a7bb922c4d4bfa1a9de9ecbc5d414018d6ad")
    add_configs("jsbind", { description = "Enable js binding", default = is_plat("wasm"), type = "boolean", readonly = true })
    if is_plat("cross | arm64") or is_plat("wasm") or is_plat("bsd") then
         add_configs("parallel",
            { description = "Enable parallel processing", default = false, type = "boolean", readonly = true }) --tbb not support arm64 cross build
    else
        add_configs("parallel",
            { description = "Enable parallel processing", default = true, type = "boolean"})
    end
    add_configs("cbind", { description = "Enable c binding", default = true, type = "boolean" }) --requires no deps
    add_configs("pybind", { description = "Enable python binding", default = false, type = "boolean" })
    add_configs("cross_section", { description = "Enable 2d simple operation", default = true, type = "boolean" })
    add_configs("exporter", { description = "Enable exporting models", default = true, type = "boolean" })
    add_configs("cmake_args", {description = "CMake args.", default = {}, type = "table"})
    if is_plat("windows", "mingw") then
        add_configs("shared",
            { description = "Build shared library.", default = false, type = "boolean", readonly = true })               --author said it may be tricky if you chose to build shared library
    end
    add_configs("tracy", { description = "Enable profiling", default = false, type = "boolean" }) --for profiling,should be disabled by default

    add_deps("cmake")

    on_load(function(package)
        if package:config("exporter") then
            package:add("deps", "assimp")
        end

        if package:config("parallel") then
            package:add("deps", "tbb")
        end

        if package:config("cross_section") then
            package:add("deps", "clipper2")
        end

        if package:config("pybind") then
            package:add("deps", "nanobind")
        end
    end)

    on_install(function(package)
        local configs = {}
        table.insert(configs, "-DCMAKE_INSTALL_PREFIX=" .. package:installdir())
        if package:config("cmake_args") then
            table.join2(configs, package:config("cmake_args"))
        end --this allows user to add more option
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DMANIFOLD_JSBIND=" .. (package:config("jsbind") and "ON" or "OFF"))
        table.insert(configs, "-DMANIFOLD_CBIND=" .. (package:config("cbind") and "ON" or "OFF"))
        table.insert(configs, "-DMANIFOLD_PYBIND=" .. (package:config("pybind") and "ON" or "OFF"))
        table.insert(configs, "-DMANIFOLD_PAR=" .. (package:config("parallel") and "ON" or "OFF"))
        table.insert(configs, "-DMANIFOLD_CROSS_SECTION=" .. (package:config("cross_section") and "ON" or "OFF"))
        table.insert(configs, "-DMANIFOLD_EXPORT=" .. (package:config("exporter") and "ON" or "OFF"))
        
        table.insert(configs, "-DTRACY_ENABLE=" .. (package:config("tracy") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DMANIFOLD_DEBUG=" .. (package:is_debug() and "ON" or "OFF"))
        table.insert(configs, "-DMANIFOLD_ASSERT=" .. (package:is_debug() and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function(package)
        assert(package:check_cxxsnippets({
            test = [[
            #include <manifold/manifold.h>
            void test() {
                manifold::Manifold cube = manifold::Manifold::Cube({1, 1, 1});
                (void)cube;
            }
        ]]
        }, { configs = { languages = "c++17" } }))
    end)

