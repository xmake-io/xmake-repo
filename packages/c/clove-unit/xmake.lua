package("clove-unit")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/fdefelici/clove-unit")
    set_description("Single-Header Unit Testing framework for C (interoperable with C++) with test autodiscovery feature")
    set_license("MIT")

    add_urls("https://github.com/fdefelici/clove-unit/archive/refs/tags/$(version).tar.gz",
             "https://github.com/fdefelici/clove-unit.git")

    add_versions("v2.4.6", "ecdbd6c4b11bc1eb6e0e5022104f053cb5d1f1ef95e04499a6e29e21289e5063")
    add_versions("v2.4.5", "e4db72612adf00d7c7c9512cb9990768f5f3e62a72039929b78ba17d5a6f4308")
    add_versions("v2.4.4", "25e611e1d4286c73d9cce7bbc99f83e00629551602351fec1edcbb669243e047")

    on_install(function (package)
        os.vcp("clove-unit.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
           CLOVE_TEST(test) {
                CLOVE_IS_TRUE(1);
            }
        ]]}, {includes = "clove-unit.h"}))
    end)
