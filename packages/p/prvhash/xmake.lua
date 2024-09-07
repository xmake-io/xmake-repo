package("prvhash")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/avaneev/prvhash")
    set_description("PRVHASH - Pseudo-Random-Value Hash")
    set_license("MIT")

    add_urls("https://github.com/avaneev/prvhash/archive/refs/tags/$(version).tar.gz",
             "https://github.com/avaneev/prvhash.git")
    add_versions("4.3.2", "e647b34e2f20134947bd3ba2b8841de251ea9da001865d9e44fdb05bd63ac741")
    add_versions("4.0", "b4d8ce80ee73e504faccd235d4071398c95b06421095eeb2502ef46a810f8375")
    
    on_install(function (package)
        os.cp("*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                uint64_t Seed = 0, lcg = 0, Hash = 0;
                uint64_t v = prvhash_core64(&Seed, &lcg, &Hash);
            }
        ]]}, {includes = "prvhash_core.h"}))
    end)
