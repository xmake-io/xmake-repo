package("mem")

    set_homepage("https://github.com/0x1F9F1/mem")
    set_description("A collection of C++11 headers useful for reverse engineering")

    set_urls("https://github.com/0x1F9F1/mem")
    
    add_versions("0.1.0", "2be6647b8f4c5cdbbd6799eaca80ad6bda07cb2097a0ddd705acff748507f615")

    on_install("windows", function (package)
        local configs = {}
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("mem::module::main()", {includes = "mem/module.h", configs = {languages = "c++11"}}))
    end)
