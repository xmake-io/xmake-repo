package("or-tools")
    set_homepage("https://developers.google.com/optimization/")
    set_description("Google's Operations Research tools")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/or-tools/archive/refs/tags/$(version).tar.gz",
             "https://github.com/google/or-tools.git")

    add_versions("v9.15", "6395a00a97ff30af878ee8d7fd5ad0ab1c7844f7219182c6d71acbee1b5f3026")

    add_configs("glpk", {description = "Enable GLPK support", default = false, type = "boolean"})
    add_configs("highs", {description = "Enable HiGHS support", default = false, type = "boolean"})

    -- NOT IMPLEMENTED YET
    add_configs("coin-or", {description = "Enable Coin-OR support", default = false, type = "boolean", readonly = true})
    add_configs("scip", {description = "Enable SCIP support", default = false, type = "boolean", readonly = true})
    add_configs("cplex", {description = "Enable CPLEX support", default = false, type = "boolean", readonly = true})
    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_links("ortools_flatzinc", "ortools")

    add_deps("cmake", "protoc")
    add_deps("zlib", "bzip2", "eigen", "re2")
    add_deps("protobuf-cpp", {configs = {zlib = true}})

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
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "OR_BUILD_DLL")
        end
    end)

    on_install(function (package)
        if not package:is_plat("windows") then
            -- Fix for RHEL/CentOS/Fedora system zlib
            io.replace("cmake/system_deps.cmake", "find_package(ZLIB REQUIRED)", "find_package(ZLIB REQUIRED MODULE)", {plain = true})
        end
        if package:is_cross() then
            os.vcp(package:dep("protoc"):dep("protobuf-cpp"):installdir("bin/*.exe"), package:dep("protobuf-cpp"):installdir("bin"))
        end

        local configs = {
            "-DBUILD_TESTING=OFF",
            "-DBUILD_EXAMPLES=OFF",
            "-DBUILD_SAMPLES=OFF",
            "-DBUILD_DEPS=OFF",
            "-DUSE_BOP=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_cross() then
            table.insert(configs, "-DOR_TOOLS_PROTOC_EXECUTABLE=" .. path.unix(package:dep("protoc"):dep("protobuf-cpp"):installdir("bin/protoc")))
        end

        table.insert(configs, "-DUSE_COINOR=" .. (package:config("coin-or") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_GLPK=" .. (package:config("glpk") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_HIGHS=" .. (package:config("highs") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_SCIP=" .. (package:config("scip") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_CPLEX=" .. (package:config("cplex") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int argc, char** argv) {
                InitGoogle(argv[0], &argc, &argv, true);
            }
        ]]
        }, {configs = {languages = "c++17"}, includes = "ortools/base/init_google.h"}))
    end)
