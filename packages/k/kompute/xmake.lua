package("kompute")
    set_homepage("https://github.com/KomputeProject/kompute")
    set_description("General purpose GPU compute framework for cross vendor graphics cards")
    set_license("Apache-2.0")

    add_urls("https://github.com/KomputeProject/kompute/archive/refs/tags/$(version).tar.gz",
             "https://github.com/KomputeProject/kompute.git")

    add_versions("v0.9.0", "901f609029033f1b97de8189228229d25508408c9f7f1dda0e75b2fa632f3521")
    add_versions("v0.8.0", "9752c6325735434e53fe6fca96946fc1a3212ff951039d1202f1c0606843b24e")

    add_deps("cmake", "vulkan-loader")

    on_install("windows", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DKOMPUTE_OPT_BUILD_AS_SHARED_LIB=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DKOMPUTE_OPT_USE_BUILT_IN_VULKAN_HEADER=" .. 1)
        import("package.tools.cmake").install(package, configs)
        os.cp("single_include", package:installdir())
        os.cp("external/fmt/include", package:installdir())
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("kp::Manager", {includes = "kompute/Kompute.hpp"}))
    end)
