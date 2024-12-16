package("orc")
    set_homepage("https://arrow.apache.org/")
    set_description("ORC is a self-describing type-aware columnar file format designed for Hadoop workloads.")
    set_license("Apache-2.0")

    add_urls("https://github.com/apache/orc/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/apache/orc.git")
    add_versions("2.0.3","7920c7c7644f31c5519befa18f8f949cdf53420603b621bd85d214b516e25ff3")
    add_configs("fPIC", {default = true, type = "boolean"})
    add_configs("build_tools", {default = false, type = "boolean"})
    add_configs("build_avx512", {default = true, type = "boolean"})

    add_deps("xmake::protobuf-cpp","xmake::lz4","xmake::snappy","xmake::zlib","xmake::zstd","cmake")
    if is_plat("macosx", "linux") then
        add_syslinks("pthread", "m")
    end
    on_install("windows|!arm*","linux|!arm*","macosx|!arm*","bsd|!arm*",function (package)
        
        local configs = {
            "-DBUILD_JAVA=OFF",
            "-DBUILD_CPP_TESTS=OFF",
            "-DBUILD_LIBHDFSPP=OFF",
            "-DINSTALL_VENDORED_LIBS=OFF",
            "-DSTOP_BUILD_ON_WARNING=OFF",
            "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON",
            "-DHAS_PRE_1970=".. (is_plat("windows") and "OFF" or "ON"),
            "-DHAS_PRE_2038=".. (is_plat("windows") and "OFF" or "ON"),
            "-DBUILD_POSITION_INDEPENDENT_LIB=".. (package:is_targetos("windows") and "OFF" or (package:config("fPIC") and "ON" or "OFF")),
            "-DBUILD_ENABLE_AVX512="..(package:is_targetos("macosx") and "OFF" or(package:config("build_avx512") and "ON" or "OFF")),
            "-DBUILD_TOOLS="..(package:config("build_tools") and "ON" or "OFF"),
            "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"),
            "-DPROTOBUF_HOME="..package:dep("protobuf-cpp"):installdir(),
            "-DLZ4_HOME="..package:dep("lz4"):installdir(),
            "-DSNAPPY_HOME="..package:dep("snappy"):installdir(),
            "-DZLIB_HOME="..package:dep("zlib"):installdir(),
            "-DZSTD_HOME="..package:dep("zstd"):installdir()
        }
        if package:dep("cmake"):version() < "1.9.0" then 
            table.insert(configs, "-DCMAKE_POLICY_DEFAULT_CMP0077=NEW")
        end
        
        import("package.tools.cmake").install(package, configs)
    end)
