package("nuraft")
    set_homepage("https://github.com/eBay/NuRaft")
    set_description("C++ implementation of Raft core logic as a replication library ")

    add_urls("https://github.com/eBay/NuRaft/archive/refs/tags/$(version).tar.gz",
             "https://github.com/eBay/NuRaft.git")
    add_versions("v2.1.0", "42d19682149cf24ae12de0dabf70d7ad7e71e49fbfa61d565e9b46e2b3cd517f")

    add_deps("cmake", "asio")

    on_install("linux", "macosx", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("nuraft.hxx"))
    end)
