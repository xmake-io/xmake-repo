package("cppast")
    set_homepage("https://github.com/foonathan/cppast")
    set_description("Library to parse and work with the C++ AST")

    add_urls("https://github.com/foonathan/cppast.git")
    add_versions("2023.02.07", "3fb7c24bc22d129e9f5cce80c7358fd725b94105")

    add_deps("cmake", "debug_assert", "tiny-process-library", "type_safe")
    add_deps("llvm", {kind = "library"})
    add_links("cppast")

    on_install("linux", function (package)
        io.replace("CMakeLists.txt", [[ OR (CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)]], "", { plain = true })
        io.replace("src/CMakeLists.txt", "-Werror -Wall -Wextra", "-Wall -Wextra", { plain = true })
        local configs = {"-DCPPAST_BUILD_TOOL=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>

            void test(const char* filepath)
            {
                cppast::libclang_compilation_database database(filepath); // the compilation database

                // simple_file_parser allows parsing multiple files and stores the results for us
                cppast::cpp_entity_index index;
                cppast::simple_file_parser<cppast::libclang_parser> parser(type_safe::ref(index));
                try
                {
                    cppast::parse_database(parser, database); // parse all files in the database
                }
                catch (cppast::libclang_error& ex)
                {
                    std::cerr << "fatal libclang error: " << ex.what() << '\n';
                }
            }
        ]]}, {configs = {languages = "c++11"}, includes = {"cppast/libclang_parser.hpp"}}))
    end)
