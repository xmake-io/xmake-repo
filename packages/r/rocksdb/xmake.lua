package("rocksdb")
    set_homepage("http://rocksdb.org")
    set_description("A library that provides an embeddable, persistent key-value store for fast storage.")

    add_urls("https://github.com/facebook/rocksdb/archive/refs/tags/$(version).tar.gz",
             "https://github.com/facebook/rocksdb.git")
    add_versions("v7.10.2", "4619ae7308cd3d11cdd36f0bfad3fb03a1ad399ca333f192b77b6b95b08e2f78")

    add_deps("cmake")

    add_configs("jemalloc", {description = "Build with JeMalloc.", default = false, type = "boolean"})
    add_configs("liburing", {description = "Build with liburing.", default = false, type = "boolean"})
    add_configs("snappy",   {description = "Build with snappy.", default = false, type = "boolean"})
    add_configs("lz4",      {description = "Build with lz4.", default = false, type = "boolean"})
    add_configs("zlib",     {description = "Build with zlib.", default = false, type = "boolean"})
    add_configs("zstd",     {description = "Build with zstd.", default = false, type = "boolean"})
    add_configs("gflags",   {description = "Build with gflags.", default = false, type = "boolean"})

    if is_plat("linux") then
        add_syslinks("pthread", "rt", "dl")
    end

    on_load(function (package)
        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                if enabled then
                    package:add("deps", name)
                end
            end
        end
    end)

    on_install("linux", "windows", "macosx", "mingw", function (package)
        local configs = {
            "-DWITH_ALL_TESTS=OFF",
            "-DWITH_TESTS=OFF",
            "-DWITH_BENCHMARK_TOOLS=OFF",
            "-DWITH_CORE_TOOLS=OFF",
            "-DWITH_TOOLS=OFF",
            "-DFAIL_ON_WARNINGS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DROCKSDB_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                table.insert(configs, "-DWITH_" .. name:upper() .. "=" .. (enabled and "ON" or "OFF"))
            end
        end
        import("package.tools.cmake").install(package, configs)
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
