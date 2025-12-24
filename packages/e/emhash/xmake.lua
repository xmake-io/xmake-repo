package("emhash")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/ktprime/emhash")
    set_description("Fast and memory efficient c++ flat hash table/map/set")
    set_license("MIT")

    add_urls("https://github.com/ktprime/emhash/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ktprime/emhash.git")

    add_versions("v1.0.1", "dbcce726c5ccce4a260a2c5ca9aa239e4d6109aacb3b5097ebfa465247708a7b")
    add_versions("v1.0.0", "9de79897a94e8c2545a401bb441ee6f6c293124e46bf9cf3023be6b1632e708b")

    add_configs("cmake", {description = "Use cmake build system", default = false, type = "boolean"})

    on_load(function (package)
        if package:config("cmake") then
            package:add("deps", "cmake")
        end
    end)

    on_install(function (package)
        if package:config("cmake") then
            import("package.tools.cmake").install(package, {"-DWITH_BENCHMARKS=OFF"})
        else
            os.cp("*.hpp", package:installdir("include"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                emhash5::HashMap<int, int> m1(4);
                m1.reserve(100);
                emhash5::HashMap<int, std::string> m2 = {
                    {1, "foo"},
                    {3, "bar"},
                    {2, "baz"},
                };
            }
        ]]}, {configs = {languages = "c++11"}, includes = "hash_table5.hpp"}))
    end)
