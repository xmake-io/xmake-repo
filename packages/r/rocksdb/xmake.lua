package("rocksdb")
    set_homepage("http://rocksdb.org")
    set_description("A library that provides an embeddable, persistent key-value store for fast storage.")
    set_license("Apache-2.0")

    add_urls("https://github.com/facebook/rocksdb/archive/refs/tags/$(version).tar.gz",
             "https://github.com/facebook/rocksdb.git")

    add_versions("v10.9.1", "e2e2e0254ddcb5338a58ba0723c90e792dbdca10aec520f7186e7b3a3e1c5223")
    add_versions("v10.7.5", "a9948bf5f00dd1e656fc40c4b0bf39001c3773ad22c56959bdb1c940d10e3d8d")
    add_versions("v10.5.1", "7ec942baab802b2845188d02bc5d4e42c29236e61bcbc08f5b3a6bdd92290c22")
    add_versions("v10.4.2", "afccfab496556904900afacf7d99887f1d50cb893e5d2288bd502db233adacac")
    add_versions("v10.0.1", "3fdc9ca996971c4c039959866382c4a3a6c8ade4abf888f3b2ff77153e07bf28")
    add_versions("v9.11.2", "0466a3c220464410687c45930f3fa944052229c894274fddb7d821397f2b8fba")
    add_versions("v9.10.0", "fdccab16133c9d927a183c2648bcea8d956fb41eb1df2aacaa73eb0b95e43724")
    add_versions("v9.9.3", "126c8409e98a3acea57446fb17faf22767f8ac763a4516288dd7c05422e33df2")
    add_versions("v9.7.4", "9b810c81731835fda0d4bbdb51d3199d901fa4395733ab63752d297da84c5a47")
    add_versions("v9.7.3", "acfabb989cbfb5b5c4d23214819b059638193ec33dad2d88373c46448d16d38b")
    add_versions("v9.7.2", "13e9c41d290199ee0185590d4fa9d327422aaf75765b3193945303c3c314e07d")
    add_versions("v9.6.1", "98cf497c1d6d0a927142d2002a0b6b4816a0998c74fda9ae7b1bdaf6b784e895")
    add_versions("v9.5.2", "b20780586d3df4a3c5bcbde341a2c1946b03d18237960bda5bc5e9538f42af40")
    add_versions("v9.4.0", "1f829976aa24b8ba432e156f52c9e0f0bd89c46dc0cc5a9a628ea70571c1551c")
    add_versions("v9.3.1", "e63f1be162998c0f49a538a7fe3fcac0e40cad77ee47d5592a65bca50f7c4620")
    add_versions("v9.2.1", "bb20fd9a07624e0dc1849a8e65833e5421960184f9c469d508b58ed8f40a780f")
    add_versions("v9.1.1", "54ca90dd782a988cd3ebc3e0e9ba9b4efd563d7eb78c5e690c2403f1b7d4a87a")
    add_versions("v9.0.0", "013aac178aa12837cbfa3b1e20e9e91ff87962ab7fdd044fd820e859f8964f9b")
    add_versions("v7.10.2", "4619ae7308cd3d11cdd36f0bfad3fb03a1ad399ca333f192b77b6b95b08e2f78")

    add_configs("jemalloc", {description = "Build with JeMalloc.", default = false, type = "boolean"})
    add_configs("liburing", {description = "Build with liburing.", default = false, type = "boolean"})
    add_configs("snappy",   {description = "Build with snappy.", default = false, type = "boolean"})
    add_configs("lz4",      {description = "Build with lz4.", default = false, type = "boolean"})
    add_configs("zlib",     {description = "Build with zlib.", default = false, type = "boolean"})
    add_configs("zstd",     {description = "Build with zstd.", default = false, type = "boolean"})
    add_configs("gflags",   {description = "Build with gflags.", default = false, type = "boolean"})
    add_configs("rtti",     {description = "Enable RTTI builds.", default = false, type = "boolean"})

    if is_plat("linux") then
        add_syslinks("pthread", "rt", "dl")
    elseif is_plat("windows", "mingw") then
        add_syslinks("shlwapi", "rpcrt4")
    end

    add_deps("cmake")

    if on_check then
        on_check("mingw", function (package)
            assert(not package:is_cross(), "package(rocksdb/mingw): cross compilation only support <= v9.1.1")
        end)
    end

    on_load(function (package)
        for name, enabled in pairs(package:configs()) do
            if (name ~= "rtti") and (not package:extraconf("configs", name, "builtin")) then
                if enabled then
                    package:add("deps", name)
                end
            end
        end
    end)

    on_install("linux", "windows|arm64", "windows|x64", "macosx", "mingw|x86_64", function (package)
        local configs = {
            "-DWITH_ALL_TESTS=OFF",
            "-DWITH_TESTS=OFF",
            "-DWITH_BENCHMARK_TOOLS=OFF",
            "-DWITH_CORE_TOOLS=OFF",
            "-DWITH_TOOLS=OFF",
            "-DWITH_TRACE_TOOLS=OFF",
            "-DFAIL_ON_WARNINGS=OFF",
            "-DROCKSDB_INSTALL_ON_WINDOWS=ON",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DROCKSDB_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        for name, enabled in pairs(package:configs()) do
            if name == "rtti" then
                if enabled then
                    table.insert(configs, "-DUSE_RTTI=1")
                end
            elseif not package:extraconf("configs", name, "builtin") then
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
        ]]}, {configs = {languages = package:version():ge("10.7.0") and "c++20" or "c++17"}, includes = "rocksdb/db.h"}))
    end)
