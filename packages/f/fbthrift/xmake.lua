package("fbthrift")
    set_homepage("https://github.com/facebook/fbthrift")
    set_description("Facebook's branch of Apache Thrift, including a new C++ server.")
    set_license("Apache-2.0")

    add_urls("https://github.com/facebook/fbthrift/archive/refs/tags/v$(version).00.tar.gz",
             "https://github.com/facebook/fbthrift.git")
    add_versions("2024.03.04", "b4981e2ec827fdf2992cb834a6c3da7d475c9dd374b8ada333d4f578b5107460")

    add_deps("cmake", "folly", "fizz", "wangle", "mvfst", "zstd", "python")

    on_install("linux", function (package)
        local configs = {"-DBUILD_TESTS=OFF",
                         "-DBUILD_EXAMPLES=OFF",
                         "-DCMAKE_CXX_STANDARD=17"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("thrift/lib/cpp2/async/HeaderClientChannel.h", {configs = {languages = "c++17"}}))
    end)
