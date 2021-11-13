package("mfast")

    set_homepage("https://github.com/objectcomputing/mFAST")
    set_description("High performance C++ encoding/decoding library for FAST (FIX Adapted for STreaming) protocol.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/objectcomputing/mFAST/archive/refs/tags/$(version).zip",
             "https://github.com/objectcomputing/mFAST.git")
    add_versions("v1.2.2", "bcfde8de2a621021841e330438f404041cd285bf10b4dc041f164876f3d8b692")

    add_patches("v1.2.2", path.join(os.scriptdir(), "patches", "v1.2.2", "tinyxml2.patch"), "e0b92fa386ca9e0c1265391b9bb5505410cf82902d41126c786b7fe9a36f2b6b")
    add_patches("v1.2.2", path.join(os.scriptdir(), "patches", "v1.2.2", "boost_multiprecision.patch"), "f9fc628c3ef439bee671f6018fced0f2ee46ee6f55d2bd1d501303dad9942feb")

    add_configs("sqlite", {description = "Build with SQLite support.", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("boost", {configs = {container = true, date_time = true, exception = true, iostreams = true, regex = true}})
    add_deps("tinyxml2")

    on_load(function (package)
        if package:config("sqlite") then
            package:add("deps", "sqlite3")
        end
    end)

    on_install("linux", "macosx", "windows", function (package)
        local configs = {"-DBUILD_TESTS=OFF",
                         "-DBUILD_EXAMPLES=OFF",
                         "-DBUILD_PACKAGES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("sqlite") then
            table.insert(configs, "-DBUILD_SQLITE3=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("mfast::fast_decoder", {configs = {languages = "c++14"}, includes = "mfast/coder/fast_decoder.h"}))
    end)
