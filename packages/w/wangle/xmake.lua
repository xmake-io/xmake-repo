package("wangle")
    set_homepage("https://github.com/facebook/wangle")
    set_description("Wangle is a framework providing a set of common client/server abstractions for building services in a consistent, modular, and composable way.")
    set_license("Apache-2.0")

    add_urls("https://github.com/facebook/wangle/releases/download/v$(version).00/wangle-v$(version).00.zip",
             "https://github.com/facebook/wangle.git")
    add_versions("2024.02.26", "762d24613d17899b3a943285f54c20e680d382ab3d6889aeb0cf92092238d733")
    add_versions("2024.03.04", "9f9e45dd7afb9aa071f9e6bfe83ccdf67cae7b6cc0a2b6db774fb68ab3152974")

    add_deps("cmake", "folly", "fizz")

    on_install("linux", function (package)
        os.cd("wangle")
        local configs = {"-DBUILD_TESTS=OFF",
                         "-DBUILD_EXAMPLES=OFF",
                         "-DCMAKE_CXX_STANDARD=17"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("wangle/channel/AsyncSocketHandler.h", {configs = {languages = "c++17"}}))
    end)
