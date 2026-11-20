package("praxo-core-cpp")
    set_homepage("https://github.com/axisvela/praxo-core")
    set_description("C++20 agent runtime with policy, tools, streaming, and plugin hosts")
    set_license("MIT")

    add_urls("https://github.com/axisvela/praxo-core/archive/refs/tags/cpp/v$(version).tar.gz")
    add_versions("0.9.0", "1aa9b3a2ec53572efb1c5c6f70c10f8ecb851a3d7aaeec926d6638c1deb7ff20")

    add_deps("cmake")

    on_install(function (package)
        local oldir = os.cd("language/cpp")
        import("package.tools.cmake").install(package, {"-DBUILD_TESTING=OFF"})
        os.cd(oldir)
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("praxo/agent.hpp", {configs = {languages = "c++20"}}))
    end)
