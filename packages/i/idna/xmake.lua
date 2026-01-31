package("idna")
    set_homepage("https://github.com/ada-url/idna")
    set_description("C++ library implementing the to_ascii and to_unicode functions from the Unicode Technical Standard.")
    set_license("Apache-2.0")

    set_urls("https://github.com/ada-url/idna/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ada-url/idna.git")

    add_versions("0.4.0", "82f168993cdbb79f633242538e70f3b753118b091a9a91aaf4d0522a1e5ec285")
    add_versions("0.3.4", "67d15822575ef4ea3c9b71e0dc72cead86c45e0ba51c11722f9166f1f595c613")
    add_versions("0.3.3", "5afa8194d7a2c5b78e4aa716d386e3a550c785efdd9478c04b7b91d57c945c80")
    add_versions("0.3.2", "3fffd81d11d5dea6ea0dd5bcd9fa6e9faa6d766ead3e1936229ec47997b90ec9")
    add_versions("0.2.0", "fa9aac3611d11ef4c0196d74bfbf5d12b87814b62d70c101e8eb74fb65c636c9")

    add_deps("cmake")

    if on_check then
        on_check(function (package)
            assert(package:check_cxxsnippets({test = [[
                #include <ranges>
                void test() {}
            ]]}, {configs = {languages = "c++20"}}), "package(idna) require at least C++20.")
        end)
    end

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
