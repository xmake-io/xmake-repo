package("libwebsockets")

    set_homepage("https://github.com/warmcat/libwebsockets")
    set_description("canonical libwebsockets.org websocket library")

    set_urls("https://github.com/warmcat/libwebsockets/archive/$(version).tar.gz",
             "https://github.com/warmcat/libwebsockets.git")

    add_versions("v4.3.2", "6a85a1bccf25acc7e8e5383e4934c9b32a102880d1e4c37c70b27ae2a42406e1")
    add_versions("v4.1.6", "402e9a8df553c9cd2aff5d7a9758e9e5285bf3070c82539082864633db3deb83")

    add_deps("cmake")

    add_configs("ssl", { description = "Enable ssl (default: openssl).", default = false, type = "boolean"})

    if is_plat("windows") then
        add_syslinks("ws2_32")
    end

    on_load(function (package)
        if package:config("ssl") then
            package:add("deps", "openssl")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        local configs = {}
        table.insert(configs, "-DLWS_WITH_SSL=" .. (package:config("ssl") and "ON" or "OFF"))
        table.insert(configs, "-DLWS_WITH_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DLWS_LINK_TESTAPPS_DYNAMIC=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLWS_WITH_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lws_create_context", {includes = "libwebsockets.h"}))
    end)

