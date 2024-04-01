package("idna")
    set_homepage("https://github.com/ada-url/idna")
    set_description("C++ library implementing the to_ascii and to_unicode functions from the Unicode Technical Standard.")
    set_license("Apache-2.0")

    add_urls("https://github.com/ada-url/idna.git")
    add_versions("2024.02.28", "fff988508f659ef5c6494572ebea3d5db2466ed0")

    add_deps("cmake")

    on_install(function (package)
        io.replace("CMakeLists.txt", "add_subdirectory(singleheader)", "", {plain = true})

        local configs = {"-DBUILD_TESTING=OFF", "-DADA_IDNA_BENCHMARKS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <ada/idna/to_ascii.h>
            void test() {
                std::string_view input = u8"meßagefactory.ca";
                std::string idna_ascii = ada::idna::to_ascii(input);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
