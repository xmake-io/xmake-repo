package("vectorscan")
    set_homepage("https://www.vectorcamp.gr/project/vectorscan/")
    set_description("A portable fork of the high-performance regular expression matching library")
    set_license("BSD-3")

    add_urls("https://github.com/VectorCamp/vectorscan/archive/refs/tags/vectorscan/$(version).tar.gz", {alias = "archive"})
    add_urls("https://github.com/VectorCamp/vectorscan.git", {alias = "github"})

    add_versions("github:5.4.12", "vectorscan/5.4.12")
    add_versions("archive:5.4.12", "1ac4f3c038ac163973f107ac4423a6b246b181ffd97fdd371696b2517ec9b3ed")

    add_deps("cmake", "ragel", "python")
    add_deps("boost", {configs = {
        exception = true,
        container = true,
        thread = true,
        graph = true
    }})

    -- currently no ragel package for ARM Windows
    on_install("linux", "windows|!arm", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("hs_compile", {includes = "hs/hs.h"}))
    end)

