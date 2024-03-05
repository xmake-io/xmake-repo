package("fizz")
    set_homepage("https://github.com/facebookincubator/fizz")
    set_description("C++14 implementation of the TLS-1.3 standard ")
    set_license("BSD")

    add_urls("https://github.com/facebookincubator/fizz/releases/download/v$(version).00/fizz-v$(version).00.zip",
             "https://github.com/facebookincubator/fizz.git")
    add_versions("2024.02.26", "fa389dca0c49e14e83e089f07f896bf616757b3c70723ddfac7be2e3fd1f312f")
    add_versions("2024.03.04", "1a7da63780ae1bbcc00f9a317911e814a49f84e4d9009254328ea0a5e121817f")

    add_deps("cmake", "folly", "libsodium")

    on_install("linux", "macosx", function (package)
        os.cd("fizz")
        local configs = {"-DBUILD_TESTS=OFF",
                         "-DBUILD_EXAMPLES=OFF",
                         "-DCMAKE_CXX_STANDARD=17"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("fizz/server/AsyncFizzServer.h", {configs = {languages = "c++17"}}))
    end)
