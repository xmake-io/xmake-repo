package("or-tools")
    set_homepage("https://developers.google.com/optimization/")
    set_description("Google's Operations Research tools")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/or-tools/archive/refs/tags/$(version).tar.gz",
                "https://github.com/google/or-tools.git")

    add_versions("v9.15", "6395a00a97ff30af878ee8d7fd5ad0ab1c7844f7219182c6d71acbee1b5f3026")

    add_deps("cmake")
    add_deps("zlib", "bzip2", "abseil", "protobuf-cpp", "re2", "eigen")

    add_configs("glpk", {description = "Enable GLPK support", default = false, type = "boolean"})
    add_configs("highs", {description = "Enable HiGHS support", default = false, type = "boolean"})

    -- NOT IMPLEMENTED YET
    add_configs("coin-or", {description = "Enable Coin-OR support", default = false, type = "boolean", readonly = true})
    add_configs("scip", {description = "Enable SCIP support", default = false, type = "boolean", readonly = true})
    add_configs("cplex", {description = "Enable CPLEX support", default = false, type = "boolean", readonly = true})

    on_install(function (package)
        local configs = {
            "-DBUILD_CXX=ON",
            "-DBUILD_SAMPLES=OFF",
            "-DBUILD_TESTING=OFF",
            "-DUSE_COINOR=" .. (package:config("coin-or") and "ON" or "OFF"),
            "-DUSE_GLPK=" .. (package:config("glpk") and "ON" or "OFF"),
            "-DUSE_HIGHS=" .. (package:config("highs") and "ON" or "OFF"),
            "-DUSE_SCIP=" .. (package:config("scip") and "ON" or "OFF"),
            "-DUSE_CPLEX=" .. (package:config("cplex") and "ON" or "OFF"),
            "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"),
            "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF")
        }
        import("package.tools.cmake").install(package, configs)
    end)

    on_load(function (package)
        if package:config("coin-or") then
            package:add("deps", "coin-or-osi", "coin-or-clp", "coin-or-asl", "coin-or-coinutils")
        end
        if package:config("glpk") then
            package:add("deps", "glpk")
        end
        if package:config("highs") then
            package:add("deps", "highs")
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            int main(int argc, char** argv) {
                InitGoogle(argv[0], &argc, &argv, true);
            }
        ]]
        }, {configs = {languages = "c++20"}, includes = "ortools/base/init_google.h"}))
    end)
