package("spdlog")

    set_homepage("https://github.com/gabime/spdlog")
    set_description("Fast C++ logging library.")

    set_urls("https://github.com/gabime/spdlog/archive/v$(version).tar.gz",
             "https://github.com/gabime/spdlog.git")

    add_versions("1.3.1", "160845266e94db1d4922ef755637f6901266731c4cb3b30b45bf41efa0e6ab70")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("spdlog::info(\"\")", {includes = "spdlog/spdlog.h", configs = {languages = "c++11"}}))
    end)
