package("arrow")

    set_homepage("https://arrow.apache.org/")
    set_description("Apache Arrow is a multi-language toolbox for accelerated data interchange and in-memory processing")
    set_license("Apache-2.0")

    add_urls("https://github.com/apache/arrow/archive/refs/tags/apache-arrow-$(version).tar.gz",
             "https://github.com/apache/arrow.git")
    add_versions('7.0.0', '57e13c62f27b710e1de54fd30faed612aefa22aa41fa2c0c3bacd204dd18a8f3')

    add_configs(csv,      {description = "CSV reader module", default = true, type = "boolean"})
    add_configs(json,     {description = "JSON reader module", default = false, type = "boolean"})
    add_configs(engine,   {description = "Build the Arrow Execution Engine", default = true, type = "boolean"})
    add_configs(dataset,  {description = "Dataset API, implies the Filesystem API", default = true, type = "boolean"})
    add_configs(orc,      {description = "Arrow integration with Apache ORC", default = false, type = "boolean"})
    add_configs(parquet,  {description = "Apache Parquet libraries and Arrow integration", default = false, type = "boolean"})
    add_configs(python,   {description = "Enable Python C++ integration library. Requires python and numpy (not managed by xrepo).", default = false, type = "boolean"})
    -- Arrow uses vendored mimalloc and jemalloc. Do not add these two libraries to configdeps.
    add_configs(mimalloc, {description = "Build the Arrow mimalloc-based allocator", default = true, type = "boolean"})
    add_configs(jemalloc, {description = "Build the Arrow jemalloc-based allocator", default = false, type = "boolean"})

    -- Some libraries are required for build with our default config settings.
    local configdeps = {
        re2 = "re2", utf8proc = "utf8proc",
        -- compression libraries
        brotli = "brotli", bz2 = "bz2", snappy = "snappy", lz4 = "lz4", zlib = "zlib", zstd = "std",
    }
    for config, dep in pairs(configdeps) do
        add_configs(config, {description = "Enable " .. dep .. " support.", default = false, type = "boolean"})
    end

    add_deps("cmake", "boost")

    on_load(function (package)
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
            cprint([[
${yellow}In case of boost dependency conflicts, please use following code (order is important):

    local boost_config = {configs = {system = true}} -- change this according to what your need
    add_requires("thrift")
    add_requireconfs("thrift.boost", boost_config)
    add_requires("arrow", {configs = {parquet = true}})
    add_requireconfs("arrow.boost", boost_config)
]])
            package:add("deps", "thrift", configs)
        end
    end)

    on_install("linux", "macosx", "bsd", function (package)
        local configs = {
            "-DARROW_BUILD_TESTS=OFF",
            "-DARROW_DEPENDENCY_SOURCE=SYSTEM",
        }

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))

        local shared = package:config("shared")
        table.insert(configs, "-DARROW_BUILD_STATIC=" .. (shared and "OFF" or "ON"))
        table.insert(configs, "-DARROW_BUILD_SHARED=" .. (shared and "ON" or "OFF"))
        table.insert(configs, "-DARROW_DEPENDENCY_USE_SHARED=" .. (shared and "ON" or "OFF"))

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
        ]]}, {configs = {languages = "c++11"}, includes = "arrow/api.h"}))
    end)
