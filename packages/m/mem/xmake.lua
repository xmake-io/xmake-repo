package("mem")

    set_homepage("https://github.com/0x1F9F1/mem")
    set_description("A collection of C++11 headers useful for reverse engineering")

    set_urls("https://github.com/0x1F9F1/mem.git")

    add_versions("0.1.0", "db0289a50da77101c4e827b92b39f06ba2e90f76")

    on_install("windows", function (package)
        os.cp("include/mem", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("mem::module::main()", {includes = "mem/module.h", configs = {languages = "c++11"}}))
    end)
