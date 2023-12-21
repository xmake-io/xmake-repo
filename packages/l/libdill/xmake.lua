package("libdill")
    set_homepage("https://github.com/sustrik/libdill")
    set_description("Structured concurrency in C")
    set_license("MIT")

    add_urls("https://github.com/sustrik/libdill.git")
    add_versions("2022.08.10", "32d0e8b733416208e0412a56490332772bc5c6e1")

    add_deps("cmake")
    add_deps("openssl")

    on_install("macosx", "linux", function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {packagedeps = "openssl"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("dill_tcp_listen", {includes = "libdill.h"}))
    end)
