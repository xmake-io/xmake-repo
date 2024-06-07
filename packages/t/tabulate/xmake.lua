package("tabulate")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/p-ranav/tabulate")
    set_description("Table Maker for Modern C++")
    set_license("MIT")

    add_urls("https://github.com/p-ranav/tabulate/archive/refs/tags/$(version).tar.gz",
             "https://github.com/p-ranav/tabulate.git")

    add_versions("v1.5", "16b289f46306283544bb593f4601e80d6ea51248fde52e910cc569ef08eba3fb")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                tabulate::Table test{};
            }
        ]]}, {configs = {languages = "c++11"}, includes = "tabulate/table.hpp"}))
    end)
