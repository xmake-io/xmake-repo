package("leveldb")

    set_homepage("https://github.com/google/leveldb")
    set_description("LevelDB is a fast key-value storage library written at Google that provides an ordered mapping from string keys to string values.")

    add_urls("https://github.com/google/leveldb/archive/$(version).tar.gz",
             "https://github.com/google/leveldb.git")
    add_versions("1.22", "55423cac9e3306f4a9502c738a001e4a339d1a38ffbee7572d4a07d5d63949b2")
    add_versions("1.23", "9a37f8a6174f09bd622bc723b55881dc541cd50747cbd08831c2a82d620f6d76")

    add_deps("cmake")
    add_deps("snappy")
    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_install("macosx", "linux", "windows", "mingw", function (package)
        local configs = {"-DLEVELDB_BUILD_TESTS=OFF", "-DLEVELDB_BUILD_BENCHMARKS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                leveldb::DB* db;
                leveldb::Options options;
                options.create_if_missing = true;
                leveldb::Status status = leveldb::DB::Open(options, "./test", &db);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "leveldb/db.h"}))
    end)
