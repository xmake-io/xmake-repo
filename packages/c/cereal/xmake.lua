package("cereal")

    set_homepage("https://uscilab.github.io/cereal/index.html")
    set_description("cereal is a header-only C++11 serialization library.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/USCiLab/cereal/archive/v$(version).tar.gz")
    add_versions("1.3.0", "329ea3e3130b026c03a4acc50e168e7daff4e6e661bc6a7dfec0d77b570851d5")
    add_versions("1.3.1", "65ea6ddda98f4274f5c10fb3e07b2269ccdd1e5cbb227be6a2fd78b8f382c976")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <fstream>
            void test() {
                std::ofstream os("out.cereal", std::ios::binary);
                cereal::BinaryOutputArchive archive( os );
            }
        ]]}, {configs = {languages = "c++11"}, includes = "cereal/archives/binary.hpp"}))
    end)
