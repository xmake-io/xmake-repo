package("duckdb")
    set_homepage("http://duckdb.org/")
    set_description("DuckDB is an in-process SQL OLAP Database Management System")
    set_license("MIT")

    if is_plat("windows") then
        add_urls("https://github.com/duckdb/duckdb/archive/refs/tags/$(version).tar.gz",
                "https://github.com/duckdb/duckdb.git")
        add_versions("v1.3.2", "a10b388e516f6d9cc5d571fa55f14c936b73a2ca17400a76aae6c3f1cc2e20cb")
        add_deps("cmake", "python")
    else
        add_urls("https://github.com/duckdb/duckdb/releases/download/$(version)/libduckdb-src.zip",
                "https://github.com/duckdb/duckdb.git")
        add_versions("v1.3.2", "3fc8b872f1e65e1271bb4c7ba698ffc28127968437a99500c44262c01f3de841")
        add_versions("v1.2.2", "478a4e2300d12cd5f494e5ae3d9dbdc7d71ae0e85bccfb72aa0b7731660eece9")
        add_versions("v1.2.1", "c7f21c12039e951dbb74e064ba218a4ca8b4b0a612d40c62d95a858ecaf2fb53")
        add_versions("v1.1.3", "66beec9f299c56f508fec3d647faa86a596d39b2d4e26bd6991b29d07b818f83")
        add_versions("v1.1.2", "8b30ec65addfe423fc18f8403bd958953d01a3193ec8b3bc2e43073433d94e47")
        add_versions("v1.1.1", "48f1ca566ae0f73fb536aec22d599917f47c26ea7ae300380e7ae3f39e29af4d")
        add_versions("v1.0.0", "482c7f090cac4408eed5b02708b6a54168c1875c2c6d8042d8344edee3f70eb7")
        add_versions("v0.10.3", "f22ed5058188c81886dfdda80c6c46b7df2ed0a623a348c78ac8372451c84497")
        add_versions("v0.10.2", "6bab203dc2e10432edbefda7be7043f73f17c8898ba81ce3aa2319e7e2d5af10")
        add_versions("v0.10.1", "70ec6ffefd9a04bf9fcdc1a4949611f9633f10f0e3b9cead1425b926a54d0f89")
        add_versions("v0.10.0", "385e27aa67712813e4a07389465c4c5c45c431d97cddd35713b8a306d2a86f2d")
    end

    on_install("macosx", "linux", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("c++17")
            target("duckdb")
                set_kind("$(kind)")
                add_files("duckdb.cpp")
                add_headerfiles("duckdb.hpp", "duckdb.h")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_install("windows|x64", function (package)
        io.replace("src/include/duckdb/common/common.hpp", "#pragma once",
            [[#pragma once
            #ifdef _WIN32
            #include "duckdb/common/windows.hpp"
            #undef OPTIONAL
            #endif
        ]])
        io.writefile("bundled_extensions.cmake", [[
            duckdb_extension_load(icu)
            duckdb_extension_load(json)
            duckdb_extension_load(parquet)
            duckdb_extension_load(autocomplete)
            duckdb_extension_load(tpcds DONT_LINK)
            duckdb_extension_load(tpch DONT_LINK)
        ]])
        local configs = {
            "-DBUILD_UNITTESTS=OFF",
            "-DENABLE_UNITTEST_CPP_TESTS=OFF",
            "-DCMAKE_GENERATOR_PLATFORM=x64",
            "-DENABLE_EXTENSION_AUTOLOADING=1",
            "-DENABLE_EXTENSION_AUTOINSTALL=1",
            "-DDISABLE_UNITY=1",
            "-DDUCKDB_EXTENSION_CONFIGS=bundled_extensions.cmake"
        }
        table.insert(configs, "-DOVERRIDE_GIT_DESCRIBE=" .. package:version())
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs, {cmake_generator = "Visual Studio 17 2022"})
        os.rm(path.join(package:installdir("lib"), "duckdb_*.lib" ))
        os.rm(path.join(package:installdir("lib"), "*extension*.lib" ))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "duckdb.hpp"
            using namespace duckdb;
            
            void test() {
                DuckDB db(nullptr);
                Connection con(db);
                con.Query("INSTALL parquet;"); 
                con.Query("LOAD parquet;"); 
            }
        ]]}, {configs = {languages = "cxx17"}}))
    end)
