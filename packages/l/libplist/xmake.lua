package("libplist")
    set_homepage("https://www.libimobiledevice.org/")
    set_description("Library for Apple Binary- and XML-Property Lists")
    set_license("LGPL-2.1")

    set_urls("https://github.com/libimobiledevice/libplist/archive/refs/tags/$(version).tar.gz",
             "https://github.com/libimobiledevice/libplist.git")

    add_versions("2.6.0", "e6491c2fa3370e556ac41b8705dd7f8f0e772c8f78641c3878cabd45bd84d950")
    add_versions("2.2.0", "7e654bdd5d8b96f03240227ed09057377f06ebad08e1c37d0cfa2abe6ba0cee2")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    if on_check then
        on_check(function (package)
            if package:is_plat("windows") and package:has_tool("cxx", "cl") then
                raise("package(libplist) unsupported msvc toolchain now, you can use clang toolchain\nadd_requires(\"libplist\", {configs = {toolchains = \"clang-cl\"}}))")
            end
        end)
    end

    on_load(function (package)
        if not (is_subhost("windows") or package:is_plat("windows", "android", "wasm")) then
            package:add("deps", "autotools")
        end

        if not package:config("shared") then
            package:add("defines", "LIBPLIST_STATIC")
        end
    end)

    on_install(function (package)
        local version = package:version()

        if is_subhost("windows") or package:is_plat("windows", "android", "wasm") then
            local configs = {}
            if version then
                configs.version = version
            end
            os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
            import("package.tools.xmake").install(package, configs)
        else
            if version and version:eq("2.2.0") then
                io.replace("src/plist.c", "void thread_once", "static void thread_once")
            end

            local configs = {
                "--disable-dependency-tracking",
                "--disable-silent-rules",
                "--without-cython",
            }
            table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
            table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))

            if version then
                table.insert(configs, "PACKAGE_VERSION=" .. version)
            end
            import("package.tools.autoconf").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("plist_new_dict", {includes = "plist/plist.h"}))
    end)
