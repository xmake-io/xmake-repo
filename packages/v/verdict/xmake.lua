package("verdict")
    set_homepage("https://github.com/sandialabs/verdict")
    set_description("Compute quality functions of 2 and 3-dimensional regions.")

    add_urls("https://github.com/sandialabs/verdict/archive/refs/tags/$(version).tar.gz",
             "https://github.com/sandialabs/verdict.git")

    add_versions("1.4.2", "225c8c5318f4b02e7215cefa61b5dc3f99e05147ad3fefe6ee5a3ee5b828964b")

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DVERDICT_ENABLE_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        if package:config("shared") then
            package:add("defines", "VERDICT_SHARED_LIB")
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <verdict.h>
            void test() {
                double coordinates[3][3];
                verdict::hex_edge_ratio(3, coordinates);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
