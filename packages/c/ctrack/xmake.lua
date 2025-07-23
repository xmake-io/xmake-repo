package("ctrack")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Compaile/ctrack")
    set_description("A lightweight, high-performance C++ benchmarking and tracking library for effortless function profiling in both development and production environments.")
    set_license("MIT")

    add_urls("https://github.com/Compaile/ctrack/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Compaile/ctrack.git")

    add_versions("v1.0.2", "cbe19d0a852e43da4fe675abc751464cd871b5a50af2ef7f315c0d0d68690092")

    add_configs("parallel", {description = "Enable parallel processing", default = false, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        if package:config("parallel") then
            package:add("deps", "tbb")
        else
            package:add("defines", "CTRACK_DISABLE_EXECUTION_POLICY")
        end
    end)

    on_install(function (package)
        local configs = {"-DDISABLE_EXAMPLES=ON"}
        table.insert(configs, "-DDISABLE_PAR=" .. (package:config("parallel") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                CTRACK;
            }
        ]]}, {configs = {languages = "c++17"}, includes = "ctrack.hpp"}))
    end)
