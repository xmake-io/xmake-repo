package("taglib")
    set_homepage("http://taglib.org/")
    set_description("TagLib Audio Meta-Data Library")
    set_license("LGPL-2.1")

    add_urls("https://github.com/taglib/taglib/archive/refs/tags/$(version).tar.gz",
             "https://github.com/taglib/taglib.git", {submodules = false})

    add_versions("v2.1.1", "bd57924496a272322d6f9252502da4e620b6ab9777992e8934779ebd64babd6e")
    add_versions("v2.1", "95b788b39eaebab41f7e6d1c1d05ceee01a5d1225e4b6d11ed8976e96ba90b0c")

    add_patches("v2.1", "https://github.com/taglib/taglib/pull/1275/commits/8446c9332994071f6ee18a545bbe91f44aafb077.diff", "7d5dc3a8fa0f62d8f6e3560c6c5dac6ff7bcc5a18df62b2aa5f24a734ba2f55e")

    add_deps("cmake")
    add_deps("utfcpp", "zlib")

    add_links("tag_c", "tag")

    on_install(function (package)
        if not package:config("shared") then
            package:add("defines", "TAGLIB_STATIC")
        end

        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("taglib_set_strings_unicode", {includes = "taglib/tag_c.h"}))
    end)
