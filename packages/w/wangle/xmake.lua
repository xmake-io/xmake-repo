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
    add_versions("2024.06.10", "0328a481258a399a70ee2d003be8d482529b2f26e79ea2c218a32361051ea5be")
    add_versions("2024.06.17", "9d3e2349be6f8462243beebc1245f8d82808734060d9e3d9c0cf45bbda3c1f70")
    add_versions("2024.06.24", "a4e83d477ef3c8c208f30a811772f0d551e0728f42f45bf647a82f3b82d60baf")
    add_versions("2024.07.01", "596dff77b6d6adef64e7b86f0f3e019c2ac787c92da0ddc18fbdaa4eca02cb3d")
    add_versions("2024.07.08", "b620ba5dee2f6c47c1d3002cb795524b1efe30f2689088000f010ecc0f9b03b2")
    add_versions("2024.07.15", "0b48e84db224ff090ab005ae8824af56d71cc3f86d05e996cae33235e6b0ccd0")

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
        assert(package:check_cxxsnippets({test = [[
            #include <chrono>
            #include "wangle/util/FilePoller.h"
            void test() {
                wangle::FilePoller poller(std::chrono::milliseconds(1));
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
