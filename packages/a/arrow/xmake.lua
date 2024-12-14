package("arrow")
    set_homepage("https://arrow.apache.org/")
    set_description("Apache Arrow defines a language-independent columnar memory format for flat and hierarchical data, organized for efficient analytic operations on modern hardware like CPUs and GPUs without serialization overhead. Arrow's libraries implement the format and provide building blocks for a range of use cases, including high performance analytics. ")
    set_license("Apache-2.0")
    set_urls("https://github.com/apache/arrow/archive/refs/tags/apache-arrow-$(version).tar.gz")

    add_versions("18.1.0", "026ecabd74f7b075f6c74e5448132ba40f35688a29d07616bcc1bd976676706c")
    
    --Note: gcs depends on google-cloud-sdk which is not included in xrepo
    --Note: orc depends on Apache-orc which is not included in xrepo, and can generate compile-time error at this time with gcc-14&-O3, thus left disabled
    --Note: arrow-python has been moved to pyarrow and option: -DARROW_PYTHON=ON is deprecated since 10.0.0. This will be removed in a future release; thus the "python" config option is removed.
    add_configs("build_utilities",      {description = "CBuild Arrow commandline utilities", default = false, type = "boolean"})
    add_configs("compute",      {description = "Build all computational kernel functions, ON by default", default = true, type = "boolean"})
    add_configs("csv",      {description = "CSV reader module", default = false, type = "boolean"})
    add_configs("cuda",     {description = " CUDA integration for GPU development. Depends on NVIDIA CUDA toolkit. The CUDA toolchain used to build the library can be customized by using the $CUDA_HOME environment variable.", default = false, type = "boolean"})
    add_configs("dataset",      {description = "Dataset API, implies the Filesystem API, ON bu default", default = true, type = "boolean"})
    add_configs("filesystem",      {description = "Filesystem API for accessing local and remote filesystems", default = false, type = "boolean"})
    add_configs("flight",      {description = "Arrow Flight RPC system, which depends at least on gRPC", default = false, type = "boolean"})
    add_configs("flight_sql",      {description = "Arrow Flight SQL", default = false, type = "boolean"})
    add_configs("gandiva",      {description = "Gandiva expression compiler, depends on LLVM, Protocol Buffers, and re2", default = false, type = "boolean"})
    add_configs("gandiva_java",      {description = "Gandiva JNI bindings for Java", default = false, type = "boolean"})
    add_configs("gcs",      {description = "Build Arrow with GCS support (requires the GCloud SDK for C++)", default = false, type = "boolean", readonly=true})
    add_configs("hdfs",      {description = "Arrow integration with libhdfs for accessing the Hadoop Filesystem", default = false, type = "boolean"})
    add_configs("ipc",      {description = "Build the IPC extensions, ON by default", default = true, type = "boolean"})
    add_configs("json",     {description = "JSON reader module", default = true, type = "boolean"})    
    add_configs("orc",      {description = "Arrow integration with Apache ORC", default = false, type = "boolean", readonly=true})
    add_configs("parquet",  {description = "Apache Parquet libraries and Arrow integration", default = false, type = "boolean"})
    add_configs("parquet_require_encryption",  {description = "Parquet Modular Encryption", default = false, type = "boolean"})
    add_configs("s3",  {description = "Support for Amazon S3-compatible filesystems", default = false, type = "boolean"})
    add_configs("substrait",  {description = "Build with support for Substrait", default = false, type = "boolean"})
    add_configs("tensorflow",  {description = "Apache Parquet libraries and Arrow integration", default = false, type = "boolean"})
    --Arrow uses either mimalloc or jemalloc (default) or system allocator as allocator. Do not add both jemalloc and mimalloc two libraries to configdeps simultaneously.
    add_configs("mimalloc", {description = "Build the Arrow mimalloc-based allocator", default = false, type = "boolean"})
    add_configs("jemalloc", {description = "Build the Arrow jemalloc-based allocator", default = true, type = "boolean"})
    add_configs("with_re2", {description = "Build with support for regular expressions using the re2 library, on by default and used when ARROW_COMPUTE or ARROW_GANDIVA is ON", default = true, type = "boolean"})
    add_configs("with_utf8proc", {description = "Build with support for Unicode properties using the utf8proc library, on by default and used when ARROW_COMPUTE or ARROW_GANDIVA is ON", default = true, type = "boolean"})
    -- Compression options available in Arrow:
    add_configs("with_brotli", {description = "Build support for Brotli compression", default = false, type = "boolean"})
    add_configs("with_bz2", {description = "Build support for BZ2 compression", default = false, type = "boolean"})
    add_configs("with_lz4", {description = "Build support for lz4 compression", default = false, type = "boolean"})
    add_configs("with_snappy", {description = "Build support for Snappy compression", default = false, type = "boolean"})
    add_configs("with_zlib", {description = "Build support for zlib (gzip) compression", default = false, type = "boolean"})
    add_configs("with_zstd", {description = "Build support for ZSTD compression", default = false, type = "boolean"})
    --Customized Bundle Option
    add_configs("with_all_compress_libs", {description = "Build support for all supported compress libraries, on by default", default = true, type = "boolean"})
    add_configs("arrow_dataio_bundle", {description = "If your use-case is limited to reading/writing Arrow data (feather, parquet, csv, json), then this options should be sufficient; default ON", default = true, type = "boolean"})
    
    ----------------------------------------------------
    --Dependencies
    add_deps("cmake", "xsimd", "openssl3")

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    if is_plat("bsd") then
        add_syslinks("pthread", "execinfo")
    end

    local configs = {
        "-DARROW_DEPENDENCY_SOURCE=SYSTEM",
        "-DARROW_BUILD_TESTS=OFF",
    }

    on_component("build_utilities", function (package, component)
        table.insert(configs, "-DARROW_BUILD_UTILITIES=ON")
    end)

    on_component("compute", function (package, component)
        component:add("deps", "with_re2", "with_utf8proc")
        table.insert(configs, "-DARROW_COMPUTE=ON")
    end)

    on_component("csv", function (package, component)
        table.insert(configs, "-DARROW_CSV=ON")
    end)

    on_component("cuda", function (package, component)
        package:add("deps", "cuda")
        table.insert(configs, "-DARROW_CUDA=ON")
    end)

    on_component("dataset", function (package, component)
        component:add("filesystem")
        table.insert(configs, "-DARROW_DATASET=ON")
    end)

    on_component("filesystem", function (package, component)
        table.insert(configs, "-DARROW_FILESYSTEM=ON")
    end)

    on_component("flight", function (package, component)
        package:add("deps", "grpc")
        package:add("deps", "gflags")
        table.insert(configs, "-DARROW_FLIGHT=ON")
    end)

    on_component("flight_sql", function (package, component)
        component:add("flight")
        table.insert(configs, "-DARROW_FLIGHT_SQL=ON")
    end)

    on_component("gandiva", function (package, component)
        package:add("deps", "llvm")
        package:add("deps", "protobuf-cpp")
        component:add("deps", "with_re2")
        table.insert(configs, "-DARROW_GANDIVA=ON")
    end)

    on_component("gandiva_java", function (package, component)
        component:add("deps", "gandiva")
        table.insert(configs, "-DARROW_GANDIVA_JAVA=ON")
    end)

    on_component("gcs", function (package, component)
        --package:add("deps", "google_cloud_cpp_storage")
        ----use the bundled version of gcs lib and coresponding compile script:
        --table.insert(configs, "-DARROW_GCS=ON")
        --table.insert(configs, "-Dgoogle_cloud_cpp_storage_SOURCE=BUNDLED")
    end)

    on_component("hdfs", function (package, component)
        table.insert(configs, "-DARROW_HDFS=ON")
    end)

    on_component("s3", function (package, component)
        package:add("deps", "aws-sdk-cpp")
        table.insert(configs, "-DARROW_S3=ON")
    end)

    on_component("ipc", function (package, component)
        table.insert(configs, "-DARROW_IPC=ON")
    end)

    on_component("jemalloc", function (package, component)
        package:add("deps", "jemalloc")
        table.insert(configs, "-DARROW_JEMALLOC=ON")
        table.insert(configs, "-DARROW_MIMALLOC=OFF")
    end)

    on_component("json", function (package, component)
        package:add("deps", "rapidjson")
        table.insert(configs, "-DARROW_JSON=ON")
    end)

    on_component("mimalloc", function (package, component)
        package:add("deps", "mimalloc")
        table.insert(configs, "-DARROW_MIMALLOC=ON")
        table.insert(configs, "-DARROW_JEMALLOC=OFF")
    end)

    on_component("orc", function (package, component)
        ----package apache orc is not included in Xrepo at this time!
        ----package:add("deps", "orc")
        --package:add("deps", "orc")
        --package:add("deps", "protobuf-cpp")
        --package:add("deps", "lz4")
        --package:add("deps", "snappy")
        --package:add("deps", "zlib")
        --package:add("deps", "zstd")
        --table.insert(configs, "-DARROW_ORC=ON")
    end)

    on_component("parquet", function (package, component)
        package:add("deps", "thrift")
        table.insert(configs, "-DARROW_PARQUET=ON")
    end)
    
    on_component("parquet_require_encryption", function (package, component)
        component:add("deps", "parquet")
        table.insert(configs, "-DPARQUET_REQUIRE_ENCRYPTION=ON")
    end)

    on_component("tensorflow", function (package, component)
        table.insert(configs, "-DARROW_TENSORFLOW=ON")
    end)

    --sub components
    on_component("with_re2", function (package, component)
        package:add("deps", "re2")
        table.insert(configs, "-DARROW_WITH_RE2=ON")
    end)

    on_component("with_utf8proc", function (package, component)
        package:add("deps", "utf8proc")
        table.insert(configs, "-DARROW_WITH_UTF8PROC=ON")
    end)

    on_component("with_bz2", function (package, component)
        package:add("deps", "bzip2")
        table.insert(configs, "-DARROW_WITH_BZ2=ON")
    end)

    on_component("with_brotli", function (package, component)
        package:add("deps", "brotli")
        table.insert(configs, "-DARROW_WITH_BROTLI=ON")
    end)

    on_component("with_lz4", function (package, component)
        package:add("deps", "lz4")
        table.insert(configs, "-DARROW_WITH_LZ4=ON")
    end)

    on_component("with_snappy", function (package, component)
        package:add("deps", "snappy")
        table.insert(configs, "-DARROW_WITH_SNAPPY=ON")
    end)

    on_component("with_zlib", function (package, component)
        package:add("deps", "zlib")
        table.insert(configs, "-DARROW_WITH_ZLIB=ON")
    end)

    on_component("with_zstd", function (package, component)
        package:add("deps", "zstd")
        table.insert(configs, "-DARROW_WITH_ZSTD=ON")
    end)
    on_load("windows", "linux", "macosx", "mingw",function (package)
        package:add("deps", "boost", {configs = {locale = true}})
        --optional components
        --Allocator
        if package:config("jemalloc") then 
            if package:config("mimalloc") then
                print("Cannot use jemalloc and mimalloc simultaneously; dismiss mimalloc")
            package:add("components","jemalloc")
        elseif package:config("mimalloc") then
                package:add("components","mimalloc")
            end 
        end
        ----Every use in data sciences:
        if package:config("arrow_dataio_bundle") then 
            package:add("components","csv", "json", "ipc","parquet", "parquet_require_encryption")
            package:add("components", "with_lz4", "with_brotli", "with_snappy", "with_zlib", "with_zstd")
        end
        if package:config("with_all_compress_libs") then 
            package:add("components","with_bz2", "with_lz4", "with_brotli", "with_snappy", "with_zlib", "with_zstd")
        end
        for _, component in ipairs({"compute", "csv", "json", "parquet","ipc", "parquet_require_encryption", "dataset","filesystem","hdfs","s3"}) do
            if package:config(component) then
                package:add("components", component)
            end
        end
        for _, component in ipairs({"with_re2", "with_utf8proc", "with_brotli", "with_bz2","with_lz4", "with_snappy", "with_zlib","with_zstd"}) do
            if package:config(component) then
                package:add("components", component)
            end
        end
        for _, component in ipairs({"cuda", "build_utilities", "tensorflow", "flight","substrait", "gandiva", "gandiva_java","with_zstd"}) do
            if package:config(component) then
                package:add("components", component)
            end
        end
        for _, component in ipairs({"orc", "gcs"}) do
            if package:config(component) then
                package:add("components", component)
            end
        end

        if is_plat("windows") then
            if package:config("shared") then
                package:add("defines", "ARROW_STATIC")
                package:add("links", "arrow_static")
                package:add("links", "arrow_bundled_dependencies")
                if package:config("flight") then
                    package:add("defines", "ARROW_FLIGHT_STATIC")
                    package:add("links", "arrow_flight_static")
                end
                if package:config("flight_sql") then
                    package:add("defines", "ARROW_FLIGHT_STATIC")
                    package:add("links", "arrow_flight_static")
                    package:add("defines", "ARROW_FLIGHT_SQL_STATIC")
                    package:add("links", "arrow_flight_sql_static")
                end
            end
        end
    end)

    on_install("windows", function (package)
        local shared = package:config("shared")
        table.insert(configs, "-DARROW_BUILD_STATIC=" .. (shared and "OFF" or "ON"))
        table.insert(configs, "-DARROW_DEPENDENCY_USE_SHARED=OFF")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        os.cd("cpp")
        import("package.tools.cmake").install(package, configs)
    end)
    on_install("linux","macosx", function (package)
        local shared = package:config("shared")
        table.insert(configs, "-DARROW_BUILD_STATIC=" .. (shared and "OFF" or "ON"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        os.cd("cpp")
        print(configs)
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                arrow::MemoryPool* pool = arrow::default_memory_pool();
                arrow::Int64Builder id_builder(pool);
                (void)id_builder;
            }
        ]]}, {configs = {languages = "c++17"}, includes = "arrow/api.h"}))
    end)
