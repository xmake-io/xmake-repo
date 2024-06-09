package("rapidhash")
    set_kind("library", {headeronly = true})
    set_description("Very fast, high quality, platform independant hashing algorithm.")
    set_homepage("https://github.com/Nicoshev/rapidhash")

    add_urls("https://github.com/Nicoshev/rapidhash.git")
    add_versions("2024.06.06", "e795829fedad966b627b316183901d2670a40af8")

    on_install(function(package)
        os.cp("rapidhash.h", package:installdir("include"))
    end)

    on_test(function(package)
        assert(package:has_cxxfuncs("rapid_mum", {includes = "rapidhash.h"}))      
    end)
