package("unordered_dense")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/martinus/unordered_dense")
    set_description("A fast & densely stored hashmap and hashset based on robin-hood backward shift deletion.")
    set_license("MIT")

    add_urls("https://github.com/martinus/unordered_dense/archive/refs/tags/$(version).tar.gz",
             "https://github.com/martinus/unordered_dense.git")
    add_versions("v1.1.0", "b47d8590afdc32b306272a6bcb15d5464462f3cd3d44653648924a1e10d1e78c")
    add_versions("v1.4.0", "36b6bfe2fe2633f9d9c537b9b808b4be6b77ff51c66d370d855f477517bc3bc9")
    add_versions("v2.0.2", "d4be48c164fa2f49deb55354b33c335688da3bd4b2299b3a46b8092602f67556")
    add_versions("v3.0.0", "e73452d7c1e274b4a15b553c0904f1de4bcfa61b00514acd1eaad7deac805ef0")
    add_versions("v4.0.4", "b34a8c942963e3a647f1bbc192a6391cd56d7ae615b2ddc1601c1779b5792206")
    add_versions("v4.4.0", "3976399793e8cb4db1409ce15610fbd9e5e406ced4745f262d393a9311efbd88")
    add_versions("v4.5.0", "2364ce4bc4c23bd02549bbb3a7572d881684cd46057f3737fd53be53669743aa")
    add_versions("v4.6.0", "f8c1787cc8ce9028f02e2a09fefbb6c89d5fa3fd4c2c3475faabbb531c9b2ab0")
    add_versions("v4.7.0", "73ce8ec4784619be4d6e54f2c4cb95d4d8dbc1fbbf24b5cf1e93b157bfa1043d")
    add_versions("v4.8.0", "29214a96de12959d8d0342a235c26d6f246c3f3e75f4bc135b6e784753513ead")
    add_versions("v4.8.1", "9f7202ec6d8353932ef865d33f5872e4b7a1356e9032da7cd09c3a0c5bb2b7de")

    add_configs("modules", {description = "Build with C++20 modules support.", default = false, type = "boolean"})

    on_load(function (package)
        if not package:config("modules") then
            package:add("deps", "cmake")
        end
    end)

    on_install(function (package)
        if not package:config("modules") then
            import("package.tools.cmake").install(package)
            os.cp("include", package:installdir())
        else
            os.cp("src/ankerl.unordered_dense.cpp", "src/ankerl.unordered_dense.cppm")
            os.tryrm("xmake.lua")
            io.writefile("xmake.lua", [[ 
                target("unordered_dense")
                    set_kind("static")
                    set_languages("c++20")
                    add_headerfiles("include/(**.h)")
                    add_includedirs("include")
                    add_files("src/**.cppm", {public = true})
            ]])
            local configs = {}
            import("package.tools.xmake").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                ankerl::unordered_dense::map<int, int> map;
                map[123] = 333;
            }
        ]]}, {configs = {languages = "c++17"}, includes = "ankerl/unordered_dense.h"}))
    end)
