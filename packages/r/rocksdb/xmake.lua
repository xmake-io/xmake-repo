package("rocksdb")
    set_homepage("http://rocksdb.org")
    set_description("A library that provides an embeddable, persistent key-value store for fast storage.")

    add_urls("https://github.com/facebook/rocksdb/archive/refs/tags/$(version).tar.gz",
             "https://github.com/facebook/rocksdb.git")
    add_versions("v7.10.2", "4619ae7308cd3d11cdd36f0bfad3fb03a1ad399ca333f192b77b6b95b08e2f78")

    add_deps("snappy")
    add_deps("lz4")
    add_deps("zlib")
    add_deps("zstd")
    add_deps("jemalloc")

    if is_plat("linux") then
        add_syslinks("pthread")
        add_syslinks("rt")
        add_syslinks("dl")
    end

    on_install("linux", "macosx", "bsd" , "mingw", function (package)
        local configs = {"PREFIX=" .. package:installdir()}
        if package:debug() then
            table.insert(configs, "DEBUG_LEVEL=2")
        end

        if package:config("shared") then
            table.insert(configs, "shared_lib")
        else
            table.insert(configs, "static_lib")
        end
        table.insert(configs, "install")
        import("package.tools.make").build(package, configs)
        if package:config("shared") then
            os.tryrm(path.join(package:installdir("lib"), "*.a"))
        end
    end)


    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                rocksdb::DB* db;
                rocksdb::Options options;
                options.create_if_missing = true;
                rocksdb::Status status = rocksdb::DB::Open(options, "./test", &db);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "rocksdb/db.h"}))
    end)

