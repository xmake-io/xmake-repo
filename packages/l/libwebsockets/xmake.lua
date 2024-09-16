package("libwebsockets")
    set_homepage("https://github.com/warmcat/libwebsockets")
    set_description("canonical libwebsockets.org websocket library")
    set_license("MIT")

    set_urls("https://github.com/warmcat/libwebsockets/archive/refs/tags/$(version).tar.gz",
             "https://github.com/warmcat/libwebsockets.git")

    add_versions("v4.3.3", "6fd33527b410a37ebc91bb64ca51bdabab12b076bc99d153d7c5dd405e4bdf90")

    add_deps("cmake")

    add_configs("ssl", {description = "Enable ssl (default: openssl).", default = false, type = "boolean"})
    add_configs("libev", {description = "Build with libev", default = false, type = "boolean"})
    add_configs("libuv", {description = "Build with libuv", default = false, type = "boolean"})
    add_configs("libevent", {description = "Build with libevent", default = false, type = "boolean"})
    add_configs("glib", {description = "Build with glib", default = false, type = "boolean"})

    add_configs("libcap", {description = "Build with libcap", default = false, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32")
    end

    if on_check then
        on_check("windows", function (package)
            import("core.base.semver")

            local msvc = package:toolchain("msvc")
            if msvc then
                local vs_sdkver = msvc:config("vs_sdkver")
                assert(vs_sdkver and semver.match(vs_sdkver):gt("10.0.19041"), "package(libwebsockets): need vs_sdkver > 10.0.19041.0")
            end
        end)
    end

    on_load(function (package)
        local deps_map = {
            ["ssl"] = "openssl"
        }
        for name, enabled in table.orderpairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                if package:config(name) then
                    local dep_name = deps_map[name]
                    if not dep_name then
                        dep_name = name
                    end
                    package:add("deps", dep_name)
                end
            end
        end
    end)

    on_install("!wasm", function (package)
        io.replace("CMakeLists.txt", "/WX", "", {plain = true})
        if not package:is_plat("linux") or not package:config("libcap") then
            io.replace("CMakeLists.txt", [[CHECK_LIBRARY_EXISTS(cap cap_set_flag "" LWS_HAVE_LIBCAP)]], "", {plain = true})
        end

        local configs = {"-DDISABLE_WERROR=ON", "-DLWS_WITH_MINIMAL_EXAMPLES=OFF", "-DLWS_WITHOUT_TESTAPPS=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLWS_WITH_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DLWS_WITH_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLWS_WITH_ASAN=" .. (package:config("asan") and "ON" or "OFF"))

        table.insert(configs, "-DLWS_WITH_SSL=" .. (package:config("ssl") and "ON" or "OFF"))
        table.insert(configs, "-DLWS_WITH_LIBEV=" .. (package:config("libev") and "ON" or "OFF"))
        table.insert(configs, "-DLWS_WITH_LIBUV=" .. (package:config("libuv") and "ON" or "OFF"))
        table.insert(configs, "-DLWS_WITH_LIBEVENT=" .. (package:config("libevent") and "ON" or "OFF"))
        table.insert(configs, "-DLWS_WITH_GLIB=" .. (package:config("glib") and "ON" or "OFF"))

        os.mkdir(path.join(package:buildir(), "lib", "pdb"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lws_create_context", {includes = "libwebsockets.h"}))
    end)
