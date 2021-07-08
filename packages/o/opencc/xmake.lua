package("opencc")

    set_homepage("https://github.com/BYVoid/OpenCC")
    set_description("Conversion between Traditional and Simplified Chinese.")

    set_urls("https://github.com/BYVoid/OpenCC/archive/ver.$(version).zip")
    add_versions("1.1.2", "b4a53564d0de446bf28c8539a8a17005a3e2b1877647b68003039e77f8f7d9c2")

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DBUILD_DOCUMENTATION=OFF", "-DENABLE_GTEST=OFF"}
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("opencc_open", {includes = "opencc/opencc.h"}))
    end)
