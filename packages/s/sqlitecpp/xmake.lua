package("sqlitecpp")
    set_homepage("http://srombauts.github.io/SQLiteCpp")
    set_description("SQLiteC++ (SQLiteCpp) is a smart and easy to use C++ SQLite3 wrapper.")
    set_license("MIT")

    set_urls("https://github.com/SRombauts/SQLiteCpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/SRombauts/SQLiteCpp.git")

    add_versions("3.3.3", "33bd4372d83bc43117928ee842be64d05e7807f511b5195f85d30015cad9cac6")
    add_versions("3.3.2", "5aa8eda130d0689bd5ed9b2074714c2dbc610f710483c61ba6cf944cebfe03af")
    add_versions("3.3.1", "71f990f9fb4b004533b6859ce40729af823b87fe691dd99ca084a7fd40db54b9")
    add_versions("3.2.1", "70c67d5680c47460f82a7abf8e6b0329bf2fb10795a982a6d8abc06adb42d693")

    if is_plat("android", "wasm") then
        add_configs("sqlite3_external", { description = "Use external sqlite3 library instead of bundled.", default = false, type = "boolean", readonly = true})
    elseif is_plat("linux", "macosx", "mingw", "msys", "bsd", "cross") then
        add_configs("sqlite3_external", { description = "Use external sqlite3 library instead of bundled.", default = true, type = "boolean", readonly = true})
    else
        add_configs("sqlite3_external", { description = "Use external sqlite3 library instead of bundled.", default = false, type = "boolean"})
    end
    add_configs("column_metadata", { description = "Enable Column::getColumnOriginName(). Require support from sqlite3 library.", default = false, type = "boolean"})
    add_configs("assert_handled", { description = "Enable the user definition of a assertion_failed() handler.", default = false, type = "boolean"})
    add_configs("has_codec", { description = "Enable database encryption API. Not available in the public release of SQLite.", default = false, type = "boolean"})
    add_configs("legacy_struct", { description = "EFallback to forward declaration of legacy struct sqlite3_value (pre SQLite 3.19)", default = false, type = "boolean"})
    add_configs("ommit_load_extension", { description = "Enable ommit load extension.", default = false, type = "boolean"})
    add_configs("filesystem", { description = "Disable the support for std::filesystem (C++17)", default = false, type = "boolean"})
    if is_plat("mingw") then
        add_configs("stack_protection", { description = "Enable stack protection for MySQL.", default = true, type = "boolean", readonly = true})
    else
        add_configs("stack_protection", { description = "Enable stack protection for MySQL.", default = true, type = "boolean"})
    end

    add_deps("cmake")

    on_load(function (package)
        if package:config("sqlite3_external") then
            package:add("deps", "sqlite3")
        end
    end)

    on_install(function (package)
        local configs =
        {
            "-DSQLITECPP_BUILD_EXAMPLES=OFF",
            "-DSQLITECPP_BUILD_TESTS=OFF",
            "-DSQLITECPP_RUN_CPPLINT=OFF",
            "-DSQLITECPP_RUN_CPPCHECK=OFF",
        }
        table.insert(configs, "-DSQLITECPP_INTERNAL_SQLITE=" .. (package:config("sqlite3_external") and "OFF" or "ON"))
        table.insert(configs, "-DSQLITE_ENABLE_COLUMN_METADATA=" .. (package:config("column_metadata") and "ON" or "OFF"))
        table.insert(configs, "-DSQLITE_ENABLE_ASSERT_HANDLER=" .. (package:config("assert_handled") and "ON" or "OFF"))
        table.insert(configs, "-DSQLITE_HAS_CODEC=" .. (package:config("has_codec") and "ON" or "OFF"))
        table.insert(configs, "-DSQLITE_USE_LEGACY_STRUCT=" .. (package:config("legacy_struct") and "ON" or "OFF"))
        table.insert(configs, "-DSQLITE_OMMIT_LOAD_EXTENSION=" .. (package:config("ommit_load_extension") and "ON" or "OFF"))
        table.insert(configs, "-DSQLITECPP_DISABLE_STD_FILESYSTEM=" .. (package:config("filesystem") and "ON" or "OFF"))
        table.insert(configs, "-DSQLITECPP_USE_STACK_PROTECTION=" .. (package:config("stack_protection") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        if package:is_plat("windows") then
            if package:config("shared") then
                if package:version():gt("3.2.1") then
                    package:add("defines", "SQLITECPP_COMPILE_DLL")
                else
                    table.remove(configs, #configs) -- BUILD_SHARED_LIBS
                    table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
                end
            end
            table.insert(configs, "-DSQLITECPP_USE_STATIC_RUNTIME=" .. (package:has_runtime("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)

        os.trycp("**.dll", package:installdir("bin"))
        os.trycp("**.so", package:installdir("lib"))
        if package:config("sqlite3_external") then
            os.tryrm(package:installdir("bin/sqlite3*"))
            os.tryrm(package:installdir("lib/sqlite3*"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                SQLite::Database db("example.db3");
            }
        ]]}, {configs = {languages = "c++11"}, includes = {"SQLiteCpp/Database.h"}}))
    end)
