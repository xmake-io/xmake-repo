package("json-c")

    set_homepage("https://github.com/json-c/json-c/wiki")
    set_description("JSON parser for C")

    set_urls("https://github.com/json-c/json-c/archive/json-c-$(version)-20180305.tar.gz")

    add_versions("0.13.1", "5d867baeb7f540abe8f3265ac18ed7a24f91fe3c5f4fd99ac3caba0708511b90")

    if is_host("windows") then
        add_deps("cmake")
    end

    on_install("windows", function (package)
        import("package.tools.cmake").install(package)
    end)
 
    on_install("linux", "macosx", function (package)
        local configs = {"--disable-dependency-tracking", "--disable-silent-rules"}
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("json_object_new_object", {includes = "json-c/json.h"}))
    end)
