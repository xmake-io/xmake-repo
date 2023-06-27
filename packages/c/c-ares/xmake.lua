package("c-ares")

    set_homepage("https://c-ares.org/")
    set_description("A C library for asynchronous DNS requests")

    add_urls("https://c-ares.org/download/c-ares-$(version).tar.gz")
    add_urls("https://github.com/c-ares/c-ares/releases/download/cares-$(version).tar.gz", {version = function (version)
        return version:gsub("%.", "_") .. "/c-ares-" .. version
    end})
    add_versions("1.16.1", "d08312d0ecc3bd48eee0a4cc0d2137c9f194e0a28de2028928c0f6cae85f86ce")
    add_versions("1.17.0", "1cecd5dbe21306c7263f8649aa6e9a37aecb985995a3489f487d98df2b40757d")
    add_versions("1.17.1", "d73dd0f6de824afd407ce10750ea081af47eba52b8a6cb307d220131ad93fc40")
    add_versions("1.17.2", "4803c844ce20ce510ef0eb83f8ea41fa24ecaae9d280c468c582d2bb25b3913d")
    add_versions("1.18.0", "71c19708ed52a60ec6f14a4a48527187619d136e6199683e77832c394b0b0af8")
    add_versions("1.18.1", "1a7d52a8a84a9fbffb1be9133c0f6e17217d91ea5a6fa61f6b4729cda78ebbcf")
    add_versions("1.19.0", "bfceba37e23fd531293829002cac0401ef49a6dc55923f7f92236585b7ad1dd3")

    add_patches("1.18.1",
                path.join(os.scriptdir(), "patches", "1.18.1", "guard-imported-lib.patch" ),
                "3cb03453af9e1477cfe926b1c03b2e3fbb8200a72888b590439e69e2d4253609")
    add_patches("1.18.1",
                path.join(os.scriptdir(), "patches", "1.18.1", "skip-docs.patch" ),
                "bbe389b4aab052c2e6845e87d1f56a8366bf18c944f5e5e6f05a2cf105dbe680")

    if is_plat("macosx") then
        add_syslinks("resolv")
    end

    add_deps("cmake")

    on_install("linux", "macosx", "windows", function (package)
        local configs = {"-DCARES_BUILD_TESTS=OFF", "-DCARES_BUILD_TOOLS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DCARES_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCARES_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        if not package:config("shared") then
            package:add("defines", "CARES_STATICLIB")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ares_library_init", {includes = "ares.h"}))
    end)
