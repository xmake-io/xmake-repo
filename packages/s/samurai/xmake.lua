package("samurai")
    set_kind("library", {headeronly = true})
    set_homepage("https://hpc-math-samurai.readthedocs.io")
    set_description("Intervals coupled with algebra of set to handle adaptive mesh refinement and operators on it.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/hpc-maths/samurai/archive/refs/tags/$(version).tar.gz",
             "https://github.com/hpc-maths/samurai.git")

    add_versions("v0.19.0", "1e8c1d287213ba8a2630d7920744cfbb1db62e7c0b5687956d61f624716100d0")
    add_versions("v0.18.0", "4e7d78dc8d6f8d1010900ccf2adfe81c66c7590f72ee3f83fe60e3e24a7ea0d0")
    add_versions("v0.16.0", "61616de42557e5cd5e9483103fd640f94f3235354e42a22a0ec76520196059a5")
    add_versions("v0.14.0", "287d0526d58b56a653d6cd68085ad2b8e3cbc69153e4fa87bb256305b3726184")
    add_versions("v0.12.0", "0cd94bda528085e6261f7e94e69821f81fd55e36560903078beb3c1025372897")
    add_versions("v0.10.0", "06739ad6ddc6d62396669e8c0a3806a375c88f3a9345519ae1c1415666229c16")
    add_versions("v0.6.0", "bab96adac8e1553b79678a22de2248bec67c7c205b5fd35e9e1aaccaca41286e")

    add_deps("xtensor", "highfive", "pugixml", "fmt")

    on_install("windows|!arm64", "linux", "macosx|!arm64", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <samurai/cell_list.hpp>
            void test() {
                samurai::CellList<2> cl;
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
