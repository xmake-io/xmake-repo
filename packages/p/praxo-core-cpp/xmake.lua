package("praxo-core-cpp")
    set_homepage("https://github.com/axisvela/praxo-core")
    set_description("C++20 agent runtime with policy, tools, streaming, and plugin hosts")
    set_license("MIT")

    add_urls("https://github.com/axisvela/praxo-core.git")
    add_versions("0.9.0", "da4cae049176c5f9d4d6912cdef3f69e1a10db41")

    on_install(function (package)
        local oldir = os.cd("language/cpp")
        import("package.tools.cmake").install(package, {"-DBUILD_TESTING=OFF"})
        os.cd(oldir)
    end)
