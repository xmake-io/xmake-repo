package("wangle")
    set_homepage("https://github.com/facebook/wangle")
    set_description("Wangle is a framework providing a set of common client/server abstractions for building services in a consistent, modular, and composable way.")
    set_license("Apache-2.0")

    add_urls("https://github.com/facebook/wangle/releases/download/v$(version).00/wangle-v$(version).00.zip",
             "https://github.com/facebook/wangle.git")
    add_versions("2024.02.26", "762d24613d17899b3a943285f54c20e680d382ab3d6889aeb0cf92092238d733")
    add_versions("2024.03.04", "9f9e45dd7afb9aa071f9e6bfe83ccdf67cae7b6cc0a2b6db774fb68ab3152974")
    add_versions("2024.03.11", "ad9fc14426c9463b9469848214e095fc1793779045bd9685c2d4d0432cb49674")
    add_versions("2024.03.18", "578986898b3464ed9bd2e392a08d07604b68b2251322518c1f819c965eebe8f2")
    add_versions("2024.03.25", "3de926ff92e59f5185e89e5e9365925530e5e57fd70f8e5107938149ce2fe140")
    add_versions("2024.04.01", "c21c3616d3017bc7b72f6b2315f81be4fd9be4c0dc6e1fae0266ec545fbc5535")

    add_deps("cmake", "folly", "fizz")

    on_install("linux", "macosx", function (package)
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
