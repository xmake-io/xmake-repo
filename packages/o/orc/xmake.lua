package("orc")
    set_homepage("https://arrow.apache.org/")
    set_description("ORC is a self-describing type-aware columnar file format designed for Hadoop workloads.")
    set_license("Apache-2.0")

    add_urls("https://github.com/apache/orc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/apache/orc.git")
    add_versions("v2.0.3","7920c7c7644f31c5519befa18f8f949cdf53420603b621bd85d214b516e25ff3")
    add_configs("tools", {default = false, type = "boolean"})
    add_configs("avx512", {default = true, type = "boolean"})

    add_deps("cmake")
    add_deps("protobuf-cpp", "lz4", "snappy", "zlib", "zstd")
    if is_plat("bsd", "linux") then
        add_syslinks("pthread", "m")
    end
    on_check(function (package)
        if package:is_arch("arm.*") then
            raise("package(orc) unsupported arm arch")
        end
    end)
    on_install("windows","linux","macosx","bsd",function (package)
        
        local configs = {
            "-DBUILD_JAVA=OFF",
            "-DBUILD_CPP_TESTS=OFF",
            "-DBUILD_LIBHDFSPP=OFF",
            "-DINSTALL_VENDORED_LIBS=OFF",
            "-DSTOP_BUILD_ON_WARNING=OFF",
            "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON",
            "-DHAS_PRE_1970=".. (is_plat("windows") and "OFF" or "ON"),
            "-DHAS_PRE_2038=".. (is_plat("windows") and "OFF" or "ON"),
            "-DBUILD_POSITION_INDEPENDENT_LIB=" .. (package:config("pic") and "ON" or "OFF"),
            "-DBUILD_ENABLE_AVX512="..(package:is_targetos("macosx") and "OFF" or(package:config("avx512") and "ON" or "OFF")),
            "-DBUILD_TOOLS="..(package:config("tools") and "ON" or "OFF"),
            "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"),
            "-DPROTOBUF_HOME="..package:dep("protobuf-cpp"):installdir(),
            "-DLZ4_HOME="..package:dep("lz4"):installdir(),
            "-DSNAPPY_HOME="..package:dep("snappy"):installdir(),
            "-DZLIB_HOME="..package:dep("zlib"):installdir(),
            "-DZSTD_HOME="..package:dep("zstd"):installdir()
        }
        if package:dep("cmake"):version():lt("1.9.0") then 
            table.insert(configs, "-DCMAKE_POLICY_DEFAULT_CMP0077=NEW")
        end
        
        import("package.tools.cmake").install(package, configs)
    end)
    on_test(function (package)
            assert(package:has_cxxincludes("orc/Type.hh"), {configs = {languages = "c++17"}})
    end)
