package("fizz")
    set_homepage("https://github.com/facebookincubator/fizz")
    set_description("C++14 implementation of the TLS-1.3 standard ")
    set_license("BSD")

    add_urls("https://github.com/facebookincubator/fizz/releases/download/v$(version).00/fizz-v$(version).00.zip",
             "https://github.com/facebookincubator/fizz.git")
    add_versions("2024.02.26", "fa389dca0c49e14e83e089f07f896bf616757b3c70723ddfac7be2e3fd1f312f")

    add_deps("cmake", "folly", "libsodium")

    on_install("linux", function (package)
        os.cd("fizz")
        local configs = { "-DBUILD_TESTS=OFF", "-DBUILD_EXAMPLES=OFF" }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("fizz/server/AsyncFizzServer.h"))
    end)
