package("marisa")

    set_homepage("https://github.com/s-yata/marisa-trie")
    set_description("Matching Algorithm with Recursively Implemented StorAge.")

    add_urls("https://github.com/s-yata/marisa-trie/archive/$(version).zip")
    add_urls("https://github.com/s-yata/marisa-trie.git")
    add_versions("v0.2.6", "8dc0b79ff9948be80fd09df6d2cc70134367339ec7d6496857bc47cf421df1af")

    add_deps("cmake")

    on_install("windows", "mingw", "linux", "macosx", "bsd", function (package)
        os.cp(path.join(package:scriptdir(), "port", "CMakeLists.txt"), "CMakeLists.txt")
        local configs = {"-DENABLE_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("marisa::Trie", {configs = {languages = "c++11"}, includes = "marisa.h"}))
    end)
