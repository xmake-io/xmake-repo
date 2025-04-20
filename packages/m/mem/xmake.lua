package("mem")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/0x1F9F1/mem")
    set_description("A collection of C++11 headers useful for reverse engineering")
    set_license("MIT")

    add_urls("https://github.com/0x1F9F1/mem/archive/refs/tags/$(version).tar.gz",
             "https://github.com/0x1F9F1/mem.git")

    add_versions("1.0.0", "db1e58b040ea39ec5794fc1dcc6749c81b062579d9f6b086d035266456bccaf3")

    on_install("windows", "linux", function (package)
        os.cp("include/mem", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("mem::module::main()", {includes = "mem/module.h", configs = {languages = "c++11"}}))
    end)
