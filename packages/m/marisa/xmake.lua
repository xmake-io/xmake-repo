package("marisa")

    set_homepage("https://github.com/s-yata/marisa-trie")
    set_description("Matching Algorithm with Recursively Implemented StorAge.")

    set_urls("https://github.com/s-yata/marisa-trie/archive/v$(version).zip")
    add_versions("0.2.6", "8dc0b79ff9948be80fd09df6d2cc70134367339ec7d6496857bc47cf421df1af")

    on_install(function (package)
        os.cp(path.join(package:scriptdir(), "port", "CMakeLists.txt"), "CMakeLists.txt")
        local configs = {"-DENABLE_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("marisa::Trie", {configs = {languages = "c++11"}, includes = "marisa.h"}))
    end)
