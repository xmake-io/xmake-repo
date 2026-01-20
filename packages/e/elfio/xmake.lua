package("elfio")
    set_kind("library", {headeronly = true})
    set_homepage("http://serge1.github.io/ELFIO")
    set_description("ELFIO - ELF (Executable and Linkable Format) reader and producer implemented as a header only C++ library")
    set_license("MIT")

    add_urls("https://github.com/serge1/ELFIO/archive/refs/tags/Release_$(version).tar.gz")
    add_versions("3.11", "c896b1c41ac19348b040e4adbd1bd14950c4c216da97f900dff726eb0adf20b2")
    add_versions("3.12", "e4ebc9ce3d6916461bc3e7765bb45e6210f0a9b93978bf91e59b05388c024489")

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DELFIO_BUILD_TESTS=OFF", "-DELFIO_BUILD_EXAMPLES=OFF"}
        if package:version():le("3.12") then
            io.replace("elfio/elf_types.hpp", "#define ELFTYPES_H", "#define ELFTYPES_H\n\n#include <stdint.h>", {plain = true})
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            #include <elfio/elfio.hpp>
            using namespace ELFIO;
            void test() {
                elfio reader;
                reader.load("");
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
