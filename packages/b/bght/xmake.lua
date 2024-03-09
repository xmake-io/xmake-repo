package("bght")

    set_kind("library", {headeronly = true})
    set_homepage("https://owensgroup.github.io/BGHT/")
    set_description("BGHT: Better GPU Hash Tables")
    set_license("Apache-2.0")

    add_urls("https://github.com/owensgroup/BGHT.git")
    add_versions("2024.03.06", "fd58966b20f76c7cd1aa1bdae58e28f6e3a7d242")

    on_install(function (package)
        os.cp("include/bght", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("bght/bcht.hpp"))
    end)
