package("duckdb")
    set_homepage("http://duckdb.org/")
    set_description("DuckDB is an in-process SQL OLAP Database Management System")
    set_license("MIT")

    add_urls("https://github.com/duckdb/duckdb/releases/download/$(version)/libduckdb-src.zip",
             "https://github.com/duckdb/duckdb.git")
    add_versions("v0.10.0", "385e27aa67712813e4a07389465c4c5c45c431d97cddd35713b8a306d2a86f2d")

    on_install("macosx", "linux", "windows", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("duckdb")
                add_files("duckdb.cpp")
                add_headerfiles("duckdb.hpp", "duckdb.h")
        ]])
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