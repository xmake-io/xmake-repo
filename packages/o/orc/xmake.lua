package("orc")
    set_homepage("https://arrow.apache.org/")
    set_description("ORC is a self-describing type-aware columnar file format designed for Hadoop workloads.")
    set_license("Apache-2.0")

    add_urls("https://github.com/apache/orc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/apache/orc.git")

    add_versions("v2.0.3", "7920c7c7644f31c5519befa18f8f949cdf53420603b621bd85d214b516e25ff3")

    add_configs("tools", {description = "build command line tools", default = false, type = "boolean"})
    add_configs("avx512", {description = "build the C++ library with AVX512 enabled if possible", default = false, type = "boolean"})

    if is_plat("linux") then
        add_extsources("pacman::apache-orc")
    end

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "m")
    end

    add_deps("cmake")
    add_deps("protobuf-cpp", "lz4", "snappy", "zlib", "zstd")

    on_check(function (package)
        if package:is_arch("arm.*") then
            raise("package(orc) unsupported arm architectures")
        end
        if package:is_cross() then
            raise("package(orc) unsupported cross-compilation")
        end
    end)

    on_install("windows", "linux", "macosx", "bsd", function (package)
        local configs = {
            "-DBUILD_JAVA=OFF",
            "-DBUILD_CPP_TESTS=OFF",
            "-DBUILD_LIBHDFSPP=OFF",
            "-DINSTALL_VENDORED_LIBS=OFF",
            "-DSTOP_BUILD_ON_WARNING=OFF",
            "-DPROTOBUF_HOME=" .. package:dep("protobuf-cpp"):installdir(),
            "-DLZ4_HOME=" .. package:dep("lz4"):installdir(),
            "-DSNAPPY_HOME=" .. package:dep("snappy"):installdir(),
            "-DZLIB_HOME=" .. package:dep("zlib"):installdir(),
            "-DZSTD_HOME=" .. package:dep("zstd"):installdir()
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_POSITION_INDEPENDENT_LIB=" .. (package:config("pic") and "ON" or "OFF"))
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        if package:dep("cmake"):version():lt("1.9.0") then 
            table.insert(configs, "-DCMAKE_POLICY_DEFAULT_CMP0077=NEW")
        end

        table.insert(configs, "-DHAS_PRE_1970=" .. (package:is_plat("windows") and "ON" or "OFF"))
        table.insert(configs, "-DHAS_PRE_2038=" .. (package:is_plat("windows") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_TOOLS=" .. (package:config("tools") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_ENABLE_AVX512=" .. (package:config("avx512") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using namespace orc;
            void test(){
                std::unique_ptr<OutputStream> outStream =writeLocalFile("my-file.orc");
                std::unique_ptr<Type> schema(Type::buildTypeFromString("struct<x:int,y:int>"));
                WriterOptions options;
                std::unique_ptr<Writer> writer =createWriter(*schema, outStream.get(), options);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "orc/OrcFile.hh"}))
    end)
