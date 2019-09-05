package("spdlog")

    set_homepage("https://github.com/gabime/spdlog")
    set_description("Fast C++ logging library.")

    set_urls("https://github.com/gabime/spdlog/archive/v$(version).zip",
             "https://github.com/gabime/spdlog.git")

    add_versions("1.3.1", "db6986d0141546d4fba5220944cc1f251bd8afdfc434bda173b4b0b6406e3cd0")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("spdlog::info(\"\")", {includes = "spdlog/spdlog.h", configs = {languages = "c++11"}}))
    end)
