package("grpc")
    set_homepage("https://grpc.io")
    set_description("The C based gRPC (C++, Python, Ruby, Objective-C, PHP, C#)")
    set_license("Apache-2.0")

    add_urls("https://github.com/grpc/grpc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/grpc/grpc.git")
    add_versions("v1.46.3", "d6cbf22cb5007af71b61c6be316a79397469c58c82a942552a62e708bce60964")

    add_deps("cmake")
    add_deps("abseil", "benchmark", "boringssl", "gtest", "libuv", "protobuf-cpp" "re2", "zlib")
    -- TODO bloaty envoy-api googleapis opencensus-proto opentelemetry xds
    if is_plat("linux") then
        add_deps("autoconf", "libtool", "pkg-config")
        add_extsources("apt::build-essential")
    elseif is_plat("macosx") then
        add_deps("autoconf", "automake", "libtool")
        add_extsources("brew::shtool")
    elseif is_plat("windows") then
        add_deps("nasm")
    end
    
    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("foo", {includes = "foo.h"}))
    end)
