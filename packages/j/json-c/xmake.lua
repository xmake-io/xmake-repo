package("json-c")

    set_homepage("https://github.com/json-c/json-c/wiki")
    set_description("JSON parser for C")

    set_urls("https://github.com/json-c/json-c/archive/json-c-$(version)-20180305.zip")

    add_versions("0.13.1", "8a244527eb4f697362f713f7d6dca3f6f9b5335e18fe7b705130ae62e599e864")

    if is_plat("windows") and winos.version():gt("winxp") then
        add_deps("cmake")
        on_install("windows", function (package)
            import("package.tools.cmake").install(package)
        end)
    end
 
    on_install("linux", "macosx", function (package)
        local configs = {"--disable-dependency-tracking", "--disable-silent-rules"}
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("json_object_new_object", {includes = "json-c/json.h"}))
    end)
