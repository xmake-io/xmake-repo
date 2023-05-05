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
    elseif is_plat("windows", "mingw") then
        add_syslinks("shlwapi", "rpcrt4")
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
            "-DFAIL_ON_WARNINGS=OFF",
            "-DROCKSDB_INSTALL_ON_WINDOWS=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DROCKSDB_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                table.insert(configs, "-DWITH_" .. name:upper() .. "=" .. (enabled and "ON" or "OFF"))
            end
        end
        if package:is_plat("windows") then
            io.replace("CMakeLists.txt", "/Zi", "", {plain = true})
            local vs_runtime = package:config("vs_runtime")
            if vs_runtime then
                table.insert(configs, "-DWITH_MD_LIBRARY=" .. (vs_runtime:startswith("MD") and "ON" or "OFF"))
            end
        end
        local cxflags
        if package:is_plat("mingw") then
            cxflags = "-DMINGW_HAS_SECURE_API"
        end
        import("package.tools.cmake").install(package, configs, {cxflags = cxflags})
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
