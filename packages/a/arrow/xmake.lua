package("arrow")
    set_homepage("https://arrow.apache.org/")
    set_description("Apache Arrow is a multi-language toolbox for accelerated data interchange and in-memory processing.")
    set_license("Apache-2.0")

    add_urls("https://github.com/apache/arrow/archive/refs/tags/apache-arrow-$(version).tar.gz",
             "https://github.com/apache/arrow.git")

    add_versions("19.0.1", "4c898504958841cc86b6f8710ecb2919f96b5e10fa8989ac10ac4fca8362d86a")
    
    --patches copied from vcpkg
    add_patches(">=18.1.0", "patches/0001-msvc-static-name.patch", "61334f14fca2f44555c6a5fe46633b2769f84a9c7fd623e9ca9daa7cddf7ae64")
    add_patches(">=18.1.0", "patches/0002-thrift.patch", "1346074f8d2412eab3d0053e35c60ab2e6a9b2f55907ee0d07f39e46aa1be7be")
    add_patches(">=18.1.0", "patches/0003-utf8proc.patch", "f10030ffbcb01e318b94084bfd91db45deb7b1ac3e2a86913c3b1b563834a81c")
    add_patches(">=18.1.0", "patches/0004-android-musl.patch", "f2a15a90969e616e4eea53f8eb0cacb9e88afbb561d2dffcd86cff7ba3aa933c")
    add_patches(">=18.1.0", "patches/0005-android-datetime.patch", "e2a3769925529171e87e0626131a2f49e8b0d8801a12f257c1cdb6af2e72245a")
    add_patches(">=18.1.0", "patches/0006-cmake-msvcruntime.patch", "1fbe797b72fb7e31255b5895539d882b9bef53be14f226a8ffe1d1ca792bc572")
    add_patches(">=18.1.0", "patches/0007-fix-path.patch", "77ca553ecfc92eb6f71692863c56c023fee6b256b831234b759bc8d22f539ab4") 
    add_patches(">=18.1.0", "patches/0008-arrow-parquet-size-statistics-include.patch", "540c16d52f512832a1de5c074d7e6a87ef427aee72b4f94051472e0dbf95a17d") 

    --Modules gcs, s3, azure, HDFS, SUBSTRAIT, Skyhooks,  tensorflow and gandiva support is not implemented yet
    add_configs("csv",      {description = "Build the Arrow CSV Parser Module", default = true, type = "boolean"})
    add_configs("json",     {description = "Build Arrow with JSON support (requires RapidJSON)" , default = true, type = "boolean"})
    add_configs("compute",   {description = "Build all Arrow Compute kernels", default = true , type = "boolean"})
    add_configs("dataset",  {description = "Build the Arrow Dataset Modules", default = true , type = "boolean"})
    add_configs("acero",  {description = "Build the Arrow Acero Engine Module", default = false , type = "boolean"})
    add_configs("orc",      {description = "Build the Arrow ORC adapter", default = true , type = "boolean"})
    add_configs("parquet",  {description =  "Build the Parquet libraries", default = true , type = "boolean"})
    add_configs("filesystem",   {description = "Build the Arrow Filesystem Layer", default = true , type = "boolean"})
    add_configs("cuda",   {description = "Build the Arrow CUDA extensions (requires CUDA toolkit)", default = false, type = "boolean"})
    add_configs("flight",   {description = "Build the Arrow Flight RPC System (requires GRPC, Protocol Buffers)", default = false , type = "boolean"})
    add_configs("flight_sql",   {description = "Build the Arrow Flight SQL extension", default = false, type = "boolean"})
    add_configs("shared_dep", {description = "Use shared library for dependency", default = false, type = "boolean"})


    add_deps("cmake",
             "xsimd",
             "brotli",
             "bzip2",
             "gflags",
             "lz4",
             "openssl",
             "re2",
             "snappy",
             "utf8proc",
             "zlib",
             "zstd",
             "rapidjson")
    add_deps("boost", {configs = {system = true,
                                  multiprecision = true,
                                  filesystem = true,
                                  locale=true,
                                  math=true,
                                  numeric=true}})
    add_deps("thrift", {configs = {compiler = true}})

    if is_plat("bsd") then
        add_syslinks("pthread", "execinfo")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    end
    if is_plat("windows") then
        add_syslinks("ole32")
    end 

    if is_plat("linux", "macosx", "bsd") then 
        add_deps("jemalloc")
    end
    on_load(function (package)
        if not package:config("shared") then 
            package:add("links", "arrow_bundled_dependencies")
            package:add("defines", "ARROW_STATIC")
            package:add("defines", "ARROW_DS_STATIC")
            package:add("defines","ARROW_ACERO_STATIC")
            package:add("defines", "ARROW_FLIGHT_STATIC")
            package:add("defines", "ARROW_FLIGHT_SQL_STATIC")
            package:add("defines", "PARQUET_STATIC")
            package:add("defines", "ARROW_ENGINE_STATIC")
            package:add("defines", "GANDIVA_STATIC")
            package:add("defines", "ARROW_ENGINE_STATIC")
        end
        package:add("links", "arrow", "arrow_bundled_dependencies") 
        if package:config("flight") then
            package:add("links", "arrow_flight")
            package:add("deps", "abseil")
            package:add("deps", "c-ares")
            package:add("deps", "grpc")
            package:add("deps", "protobuf-cpp")
        end
        if package:config("flight_sql") then
            package:add("links", "arrow_flight","arrow_flight_sql")
            package:add("deps", "abseil")
            package:add("deps", "c-ares")
            package:add("deps", "grpc")
            package:add("deps", "protobuf-cpp")
        end
        if package:config("acero") then 
            package:add("links", "arrow_acero")
        end 
        if package:config("dataset") then 
            package:add("links", "arrow_dataset","arrow_acero")
        end         
        if package:config("orc") then
            package:add("deps", "orc")
        end
        if package:config("parquet") then
            package:add("links", "parquet")
        end
        if package:config("cuda") then
            package:add("links", "arrow_cuda")
            package:add("deps", "cuda", {system=true})
        end

    end)

    on_install("windows", "linux", "macosx", "bsd", function (package)
        local configs = {
            "-DARROW_BUILD_TESTS=OFF",
            "-DARROW_DEPENDENCY_SOURCE=SYSTEM",
            "-DARROW_PACKAGE_KIND=XMAKE",
            "-DBUILD_WARNING_LEVEL=PRODUCTION",
            "-DARROW_BUILD_INTEGRATION=OFF",
            "-DARROW_BUILD_TESTS=OFF",
            "-DARROW_BUILD_EXAMPLES=OFF",
            "-DARROW_ENABLE_TIMING_TESTS=OFF",
            "-DARROW_BUILD_BENCHMARKS=OFF",
            "-DARROW_WITH_RE2=ON",
            "-DARROW_WITH_UTF8PROC=ON",
            "-DARROW_WITH_BROTLI=ON",
            "-DARROW_WITH_BZ2=ON",
            "-DARROW_WITH_LZ4=ON",
            "-DARROW_WITH_SNAPPY=ON",
            "-DARROW_WITH_ZLIB=ON",
            "-DARROW_WITH_ZSTD=ON",
            "-DARROW_IPC=ON",
            --Roots
            "-Dre2_ROOT=" .. package:dep("re2"):installdir(),
            "-DBOOST_ROOT=" .. package:dep("boost"):installdir(),
            "-Dutf8proc_ROOT=" .. package:dep("utf8proc"):installdir(),
            "-DThrift_ROOT=" .. package:dep("thrift"):installdir(),
            "-DBROTLI_ROOT=" .. package:dep("brotli"):installdir(),
            "-DLZ4_ROOT=" .. package:dep("lz4"):installdir(),
            "-DSnappy_ROOT=" .. package:dep("snappy"):installdir(),
            "-DZLIB_ROOT=" .. package:dep("zlib"):installdir(),
            "-DZSTD_ROOT=" .. package:dep("zstd"):installdir(),
            "-Dgflags_ROOT=" .. package:dep("gflags"):installdir(),
            "-DZSTD_ROOT=" .. package:dep("zstd"):installdir(),
            "-DOPENSSL_ROOT_DIR=" .. package:dep("openssl"):installdir(),
            "-DRapidJSON_ROOT=" .. package:dep("rapidjson"):installdir(),
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        local shared = package:config("shared")
        table.insert(configs, "-DARROW_BUILD_STATIC=" .. (shared and "OFF" or "ON"))
        table.insert(configs, "-DARROW_BUILD_SHARED=" .. (shared and "ON" or "OFF"))
        table.insert(configs, "-DARROW_DEPENDENCY_USE_SHARED=" .. (package:config("shared_dep") and "ON" or "OFF"))


        for config, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", config, "builtin")  then
                table.insert(configs, "-DARROW_" .. string.upper(config)  .. "=" .. (enabled and "ON" or "OFF"))
            end
        end
        if package:config("orc") then 
            table.insert(configs, "-DORC_ROOT=" .. package:dep("orc"):installdir())
        end
        if package:config("parquet") then 
            table.insert(configs, "-DPARQUET_REQUIRE_ENCRYPTION=ON")
            table.insert(configs, "-DARROW_FILESYSTEM=ON")
        end
        if package:config("acero") then 
            table.insert(configs, "-DARROW_COMPUTE=ON")
        end
        if package:config("dataset") then 
            table.insert(configs, "-DARROW_ACERO=ON")
            table.insert(configs, "-DARROW_FILESYSTEM=ON")
            table.insert(configs, "-DARROW_COMPUTE=ON")
        end
        if package:config("flight") or package:config("flight_sql") then 
            table.insert(configs, "-Dc-ares_ROOT=" .. package:dep("c-ares"):installdir())
        end
        if package:is_plat("windows") then 
            table.insert(configs, "-DARROW_MIMALLOC=ON")
            if package:toolchain("msvc") then
                table.insert(configs, "-DBROTLI_MSVC_STATIC_LIB_SUFFIX=")
                table.insert(configs, "-DPROTOBUF_MSVC_STATIC_LIB_SUFFIX=")
                table.insert(configs, "-DRE2_MSVC_STATIC_LIB_SUFFIX=")
                table.insert(configs, "-DSNAPPY_MSVC_STATIC_LIB_SUFFIX=")
                table.insert(configs, "-DLZ4_MSVC_STATIC_LIB_SUFFIX=")
                table.insert(configs, "-DLZ4_MSVC_LIB_PREFIX=")
                table.insert(configs, "-DZSTD_MSVC_STATIC_LIB_SUFFIX=")
            end
        end
        if package:is_plat("linux", "macosx", "bsd") then 
            table.insert(configs, "-DARROW_JEMALLOC=ON")
            table.insert(configs, "-Djemalloc_ROOT=" .. package:dep("jemalloc"):installdir())
        end
        table.insert(configs, "-DCMAKE_SYSTEM_PROCESSOR=" .. (package:is_arch("x86_64") and "x86_64" or "x86"))

        --https://github.com/apache/arrow/issues/43167
        -- And the same problem with parquet.encryption&openssl
        io.replace("cpp/src/parquet/CMakeLists.txt", "list(APPEND PARQUET_STATIC_LINK_LIBS thrift::thrift)", "list(APPEND PARQUET_STATIC_LINK_LIBS thrift::thrift Boost::headers OpenSSL::Crypto)", {plain = true})
        io.replace("cpp/src/parquet/CMakeLists.txt", "list(APPEND PARQUET_SHARED_PRIVATE_LINK_LIBS thrift::thrift)", "list(APPEND PARQUET_SHARED_PRIVATE_LINK_LIBS thrift::thrift Boost::headers OpenSSL::Crypto)", {plain = true})
        os.cd("cpp")
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
