package("cppli")
    set_homepage("https://cppli.bearodactyl.dev")
    set_description("an intuitive CLI framework for C++")
    
    add_urls("https://github.com/TheBearodactyl/cppli.git")

    add_versions("2025.10.22", "98c8c2e8ee65d7a5a6b160cf0b85ba1be39ffb05")

    add_patches("2025.10.22", "patches/2025.10.22/fix-clang.patch", "7d7c1363774e4279636455b7cfe4806138a272a03d10f6bfce6dda00b3b17d0d")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_deps("cmake")

    on_check(function (package)
        assert(package:check_cxxsnippets({test = [[
            #if !__has_include(<source_location>)
            #   error source_location is not supported by compiler
            #endif
        ]]}, {configs = {languages = "c++20"}}), "package(cppli): need std::source_location from <source_location> header.")
    end)

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DCPPLI_BUILD_TESTS=OFF")
        import("package.tools.cmake").install(package, configs)
    end)
    
    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                cli::Parser parser("myapp", "A test application");
                std::string help = parser.generate_help();
            }
        ]]}, {configs = {languages = "c++20"}, includes = "cppli.hpp"}))
    end)
