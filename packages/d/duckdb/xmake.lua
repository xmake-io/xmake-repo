package("duckdb")
    set_homepage("http://duckdb.org/")
    set_description("DuckDB is an in-process SQL OLAP Database Management System")
    set_license("MIT")

    add_urls("https://github.com/duckdb/duckdb/releases/download/$(version)/libduckdb-src.zip",
             "https://github.com/duckdb/duckdb.git")
    add_versions("v1.4.3", "a9d834d07524f483aa1132ee183169767008468cc485c25b2170b9e6eee47ef6")
    add_versions("v1.4.2", "ee7e178341ea8199ad52eabdff07aa89969f9904868eaa94e71efb31eaef7f2d")
    add_versions("v1.4.1", "81da1c9943f7b16e8a41456549fba72473ace3c83887e813e5610eb446c19781")
    add_versions("v1.4.0", "d1efda5fabc198d2099109f2d6a21392a7ca3888afbafe8573abcb1b09c6f15a")
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

    on_install("macosx", "linux", function (package)
        io.writefile("xmake.lua", string.format([[
            add_rules("mode.debug", "mode.release")
            add_rules("utils.install.cmake_importfiles")
            set_version("%s")
            set_languages("c++17")
            target("duckdb")
                set_kind("$(kind)")
                add_files("duckdb.cpp")
                add_headerfiles("duckdb.hpp", "duckdb.h")
        ]], package:version()))
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "duckdb.hpp"
            using namespace duckdb;
            
            void test() {
                DuckDB db(nullptr);
                Connection con(db);
            }
        ]]}, {configs = {languages = "cxx17"}}))
    end)
