package("arrow")
    -- For how to enable various features and build PyArrow python packages,
    -- refer to this discussion https://github.com/xmake-io/xmake-repo/discussions/1106 

    set_homepage("https://arrow.apache.org/")
    set_description("Apache Arrow is a multi-language toolbox for accelerated data interchange and in-memory processing")
    set_license("Apache-2.0")

    add_urls("https://github.com/apache/arrow/archive/refs/tags/apache-arrow-$(version).tar.gz",
             "https://github.com/apache/arrow.git")
    add_versions('21.0.0', 'e92401790fdba33bfb4b8aa522626d800ea7fda4b6f036aaf39849927d2cf88d')
    add_versions('7.0.0', '57e13c62f27b710e1de54fd30faed612aefa22aa41fa2c0c3bacd204dd18a8f3')

    add_configs("csv",      {description = "CSV reader module", default = true, type = "boolean"})
    add_configs("json",     {description = "JSON reader module", default = false, type = "boolean"})
    add_configs("engine",   {description = "Build the Arrow Execution Engine", default = true, type = "boolean"})
    add_configs("dataset",  {description = "Dataset API, implies the Filesystem API", default = true, type = "boolean"})
    add_configs("orc",      {description = "Arrow integration with Apache ORC", default = false, type = "boolean"})
    add_configs("parquet",  {description = "Apache Parquet libraries and Arrow integration", default = false, type = "boolean"})
    add_configs("plasma",   {description = "Plasma Shared Memory Object Store", default = false, type = "boolean"})
    add_configs("python",   {description = "Enable Python C++ integration library. Requires python and numpy (not managed by xmake/xrepo).", default = false, type = "boolean"})
    -- Arrow uses vendored mimalloc and jemalloc. Do not add these two libraries to configdeps.
    add_configs("mimalloc", {description = "Build the Arrow mimalloc-based allocator", default = true, type = "boolean"})
    add_configs("jemalloc", {description = "Build the Arrow jemalloc-based allocator", default = false, type = "boolean"})
    -- If true, arrow will look for shared libraries for third party dependency.
    -- The pyarrow python package creates shared library that links in all necessary thirdparty static libraries.
    add_configs("shared_dep", {description = "Use shared library for dependency", default = false, type = "boolean"})

    -- Some libraries are required for build with our default config settings.
    local configdeps = {
        re2 = "re2", utf8proc = "utf8proc",
        -- compression libraries
        brotli = "brotli", bz2 = "bzip2", snappy = "snappy", lz4 = "lz4", zlib = "zlib", zstd = "zstd",
    }
    for config, dep in pairs(configdeps) do
        add_configs(config, {description = "Enable " .. dep .. " support.", default = false, type = "boolean"})
    end

    add_deps("cmake >=3.25", "xsimd", "ninja")
    add_deps("boost", {configs={date_time=true, regex=true, math=true}})

    if is_plat("bsd") then
        add_syslinks("pthread", "execinfo")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    elseif is_plat("windows") then
        add_syslinks("Ole32")
    end

    on_load(function (package)
        if package:config("plasma") then
            package:add("links", "plasma")
            package:add("deps", "gflags")
        end
        if package:config("parquet") then
            package:add("links", "parquet")
        end
        if package:config("dataset") then
            package:add("links", "arrow_dataset")
        end
        package:add("links", "arrow", "arrow_bundled_dependencies")

        for name, dep in pairs(configdeps) do
            if package:config(name) then
                package:add("deps", dep)
            end
        end

        if package:config("python") then
            package:add("deps", "rapidjson")
        end
        if package:config("json") then
            package:add("deps", "rapidjson")
        end
        if package:config("orc") then
            package:add("deps", "protobuf-cpp")
            package:add("deps", "lz4")
            package:add("deps", "snappy")
            package:add("deps", "zlib")
            package:add("deps", "zstd")
        end
        if package:config("parquet") then
            package:add("deps", "thrift")
        end

        if package:is_plat("windows") then
            if not package:config("shared") then
                package:add("defines", "ARROW_STATIC")
                package:add("links", "arrow_static", "arrow_dataset_static", "arrow_compute_stati", "arrow_acero_static", "arrow_bundled_dependencies")
            else
                package:add("links", "arrow_compute", "arrow_acero")
            end
        end
    end)

    on_install("windows", "linux", "macosx", "bsd", function (package)
        local configs = {
            "-DARROW_BUILD_TESTS=OFF",
            "-DARROW_DEPENDENCY_SOURCE=SYSTEM",
        }

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))

        local shared = package:config("shared")
        table.insert(configs, "-DARROW_BUILD_STATIC=" .. (shared and "OFF" or "ON"))
        table.insert(configs, "-DARROW_BUILD_SHARED=" .. (shared and "ON" or "OFF"))
        table.insert(configs, "-DARROW_DEPENDENCY_USE_SHARED=" .. (package:config("shared_dep") and "ON" or "OFF"))

        for config, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", config, "builtin") and configdeps[config] == nil then
                table.insert(configs, "-DARROW_" .. string.upper(config)  .. "=" .. (enabled and "ON" or "OFF"))
            end
        end

        for config, dep in pairs(configdeps) do
            table.insert(configs, "-DARROW_WITH_" .. string.upper(config)  .. "=" .. (package:config(config) and "ON" or "OFF"))
        end

        -- To fix arrow src/arrow/CMakeLists.txt:538, when CMAKE_SYSTEM_NAME set but CMAKE_SYSTEM_PROCESSOR is not causing error.
        table.insert(configs, "-DCMAKE_SYSTEM_PROCESSOR=" .. (package:is_arch("x86_64") and "x86_64" or "x86"))

        os.cd("cpp")
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        if package:config("python") then
            -- test links to all libs, including python binding, which causes link error.
            return
        end
        assert(package:check_cxxsnippets({test = [[
            void test() {
                arrow::MemoryPool* pool = arrow::default_memory_pool();
                arrow::Int64Builder id_builder(pool);
                (void)id_builder;
            }
        ]]}, {configs = {languages = "c++17"}, includes = "arrow/api.h"}))
    end)
