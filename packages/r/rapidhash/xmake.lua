package("rapidhash")
    set_kind("library", {headeronly = true})
    set_description("Very fast, high quality, platform independant hashing algorithm.")
    set_homepage("https://github.com/Nicoshev/rapidhash")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/Nicoshev/rapidhash/archive/refs/tags/rapidhash_$(version).tar.gz",
             "https://github.com/Nicoshev/rapidhash.git")

    add_versions("v1.0", "d295e66eec6745cc0e0c8c65fb8b5edf08ab3af83b0a503c54c6705144b53848")

    on_install(function(package)
        os.cp("rapidhash.h", package:installdir("include"))
    end)

    on_test(function(package)
        assert(package:has_cxxfuncs("rapidhash", {configs = {languages = "c++11"}, includes = "rapidhash.h"}))
    end)
