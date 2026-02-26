package("c-ares")
    set_homepage("https://c-ares.org/")
    set_description("A C library for asynchronous DNS requests")
    set_license("MIT")

    add_urls("https://github.com/c-ares/c-ares/releases/download/$(version).tar.gz", {version = function (version)
        if version:ge("1.30.0") then
            return "v" .. version .. "/c-ares-" .. version
        else
            return "cares-" .. version:gsub("%.", "_") .. "/c-ares-" .. version
        end
    end})

    add_versions("1.34.6", "912dd7cc3b3e8a79c52fd7fb9c0f4ecf0aaa73e45efda880266a2d6e26b84ef5")
    add_versions("1.34.5", "7d935790e9af081c25c495fd13c2cfcda4792983418e96358ef6e7320ee06346")
    add_versions("1.34.4", "fa38dbed659ee4cc5a32df5e27deda575fa6852c79a72ba1af85de35a6ae222f")
    add_versions("1.34.3", "26e1f7771da23e42a18fdf1e58912a396629e53a2ac71b130af93bbcfb90adbe")
    add_versions("1.34.1", "7e846f1742ab5998aced36d170408557de5292b92ec404fb0f7422f946d60103")
    add_versions("1.33.1", "06869824094745872fa26efd4c48e622b9bd82a89ef0ce693dc682a23604f415")
    add_versions("1.33.0", "3e41df2f172041eb4ecb754a464c11ccc5046b2a1c8b1d6a40dac45d3a3b2346")
    add_versions("1.32.3", "5f02cc809aac3f6cc5edc1fac6c4423fd5616d7406ce47b904c24adf0ff2cd0f")
    add_versions("1.32.2", "072ff6b30b9682d965b87eb9b77851dc1cd8e6d8090f6821a56bd8fa89595061")
    add_versions("1.31.0", "0167a33dba96ca8de29f3f598b1e6cabe531799269fd63d0153aa0e6f5efeabd")
    add_versions("1.30.0", "4fea312112021bcef081203b1ea020109842feb58cd8a36a3d3f7e0d8bc1138c")
    add_versions("1.29.0", "0b89fa425b825c4c7bc708494f374ae69340e4d1fdc64523bdbb2750bfc02ea7")
    add_versions("1.28.1", "675a69fc54ddbf42e6830bc671eeb6cd89eeca43828eb413243fd2c0a760809d")
    add_versions("1.27.0", "0a72be66959955c43e2af2fbd03418e82a2bd5464604ec9a62147e37aceb420b")
    add_versions("1.16.1", "d08312d0ecc3bd48eee0a4cc0d2137c9f194e0a28de2028928c0f6cae85f86ce")
    add_versions("1.17.0", "1cecd5dbe21306c7263f8649aa6e9a37aecb985995a3489f487d98df2b40757d")
    add_versions("1.17.1", "d73dd0f6de824afd407ce10750ea081af47eba52b8a6cb307d220131ad93fc40")
    add_versions("1.17.2", "4803c844ce20ce510ef0eb83f8ea41fa24ecaae9d280c468c582d2bb25b3913d")
    add_versions("1.18.0", "71c19708ed52a60ec6f14a4a48527187619d136e6199683e77832c394b0b0af8")
    add_versions("1.18.1", "1a7d52a8a84a9fbffb1be9133c0f6e17217d91ea5a6fa61f6b4729cda78ebbcf")
    add_versions("1.19.0", "bfceba37e23fd531293829002cac0401ef49a6dc55923f7f92236585b7ad1dd3")

    add_patches("1.29.0", "patches/1.29.0/macosx-header.patch", "389c12e54d82f0e8d5dc38dc15bbade12592509627680498774159a0cb32faf2")
    add_patches("1.18.1", "patches/1.18.1/guard-imported-lib.patch", "3cb03453af9e1477cfe926b1c03b2e3fbb8200a72888b590439e69e2d4253609")
    add_patches("1.18.1", "patches/1.18.1/skip-docs.patch", "bbe389b4aab052c2e6845e87d1f56a8366bf18c944f5e5e6f05a2cf105dbe680")

    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    if is_plat("macosx") then
        add_syslinks("resolv")
    end

    add_deps("cmake")

    on_install(function (package)
        local shared = package:config("shared")
        local configs = {"-DCARES_BUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DCARES_SHARED=" .. (shared and "ON" or "OFF"))
        table.insert(configs, "-DCARES_STATIC=" .. (shared and "OFF" or "ON"))
        table.insert(configs, "-DCARES_BUILD_TOOLS=" .. (package:config("tools") and "ON" or "OFF"))
        if not shared then
            package:add("defines", "CARES_STATICLIB")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ares_library_init", {includes = "ares.h"}))
    end)
