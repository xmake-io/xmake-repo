package("marisa")
    set_homepage("https://github.com/s-yata/marisa-trie")
    set_description("Matching Algorithm with Recursively Implemented StorAge.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/s-yata/marisa-trie/archive/refs/tags/$(version).tar.gz",
             "https://github.com/s-yata/marisa-trie.git")

    add_versions("v0.3.1", "986ed5e2967435e3a3932a8c95980993ae5a196111e377721f0849cad4e807f3")
    add_versions("v0.2.6", "1063a27c789e75afa2ee6f1716cc6a5486631dcfcb7f4d56d6485d2462e566de")
    add_versions("v0.3.0", "a3057d0c2da0a9a57f43eb8e07b73715bc5ff053467ee8349844d01da91b5efb")

    add_patches("v0.3.0", "patches/v0.3.0/support-debug-install.diff", "a3d02bf6881d233bf8cfadded33edfcde167bee719d47538b869e0e90d8bf7ce")
    add_patches("v0.3.0", "https://github.com/s-yata/marisa-trie/pull/119.diff", "f02211699465b55cd2ab93ef20bafcd69aa573da1fd796cb9366697075074093")

    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    add_deps("cmake")

    on_install(function (package)
        if package:version() and package:version():lt("v0.3.0") then
            os.cp(path.join(package:scriptdir(), "port", "CMakeLists.txt"), "CMakeLists.txt")
        end
        -- fix install for debug build type
        io.replace("CMakeLists.txt", "CONFIGURATIONS Release", "", {plain = true})

        local configs = {
            "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW",
            "-DENABLE_TESTS=OFF",
            "-DBUILD_TESTING=OFF",
        }
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_ASAN=" .. (package:config("asan") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_TOOLS=" .. (package:config("tools") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)

        if package:version() and package:version():lt("v0.3.0") then
            os.tryrm(package:installdir("lib/pkgconfig/marisa.pc"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <marisa.h>
            void test() {
                int x = 1, y = 2;
                marisa::swap(x, y);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
