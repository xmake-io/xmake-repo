package("samurai")
    set_kind("library", {headeronly = true})
    set_homepage("https://hpc-math-samurai.readthedocs.io")
    set_description("Intervals coupled with algebra of set to handle adaptive mesh refinement and operators on it.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/hpc-maths/samurai/archive/refs/tags/$(version).tar.gz",
             "https://github.com/hpc-maths/samurai.git")

    add_versions("v0.28.0", "94a50fc30714b652157e27ac7870dc8487e1045289d87cb83b28d2c7f6834b94")
    add_versions("v0.27.1", "5cb1ffb87a6a3defbde45037bd80e8277c31d577e20559c6cb2853b82bc989ba")
    add_versions("v0.27.0", "23d3e6475fbc674a887af84333b49ff6ac68fa8326e9edfdb49fa47491c28f4f")
    add_versions("v0.26.1", "07971b2c5359cc33f5e3fb3f4f7d156b6aed91441139a1ae133378ba25e46d7a")
    add_versions("v0.25.1", "6eb053138161d4823ad4e2d400add581b0a70402d59513fd855af6b625f48bfe")
    add_versions("v0.23.0", "7f0c626b5f5671e40dc2d35c520db69c30444083b247eba1a5dc026a519b4ce3")
    add_versions("v0.22.0", "65a087ba0eb461f75b3ee4cf7725432d8c92f2a1af42220d6b233279a432429b")
    add_versions("v0.21.1", "f052ee47a4f533fb805f3d3c9c9d5462e2b041855c9e4322d902860ec572d747")
    add_versions("v0.19.0", "1e8c1d287213ba8a2630d7920744cfbb1db62e7c0b5687956d61f624716100d0")
    add_versions("v0.18.0", "4e7d78dc8d6f8d1010900ccf2adfe81c66c7590f72ee3f83fe60e3e24a7ea0d0")
    add_versions("v0.16.0", "61616de42557e5cd5e9483103fd640f94f3235354e42a22a0ec76520196059a5")
    add_versions("v0.14.0", "287d0526d58b56a653d6cd68085ad2b8e3cbc69153e4fa87bb256305b3726184")
    add_versions("v0.12.0", "0cd94bda528085e6261f7e94e69821f81fd55e36560903078beb3c1025372897")
    add_versions("v0.10.0", "06739ad6ddc6d62396669e8c0a3806a375c88f3a9345519ae1c1415666229c16")
    add_versions("v0.6.0", "bab96adac8e1553b79678a22de2248bec67c7c205b5fd35e9e1aaccaca41286e")

    add_deps("highfive", "pugixml", "fmt")

    on_load(function (package)
        if package:version() and package:version():ge("0.27.0") then
            package:add("deps", "xtensor")
        else
            package:add("deps", "xtensor <=0.25.0")
        end
    end)

    on_install("windows|!arm64", "linux", "macosx|!arm64", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        local cpp_ver = (package:version() and package:version():ge("0.20.0")) and "c++20" or "c++17"
        assert(package:check_cxxsnippets({test = [[
            #include <samurai/cell_list.hpp>
            void test() {
                samurai::CellList<2> cl;
            }
        ]]}, {configs = {languages = cpp_ver}}))
    end)
