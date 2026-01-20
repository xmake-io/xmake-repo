package("xlsxio")
    set_homepage("https://github.com/brechtsanders/xlsxio")
    set_description("XLSX I/O - C library for reading and writing .xlsx files")
    set_license("MIT")

    add_urls("https://github.com/brechtsanders/xlsxio/archive/refs/tags/$(version).tar.gz",
             "https://github.com/brechtsanders/xlsxio.git")

    add_versions("0.2.36", "80d3df95a7a108a41f83f0ce4c6706873fd2afafd92424fcccea475a8acbd044")
    add_versions("0.2.35", "03a4d1b1613953d46c8fc2ea048cd32007fbddcd376ab6d4156f72da2815adfa")
    add_versions("0.2.34", "726e3bc3cf571ac20e5c39b1f192f3793d24ebfdeaadcd210de74aa1ec100bb6")

    add_configs("libzip", {description = "Use libzip instead of Minizip", default = false, type = "boolean"})
    add_configs("minizip_ng", {description = "Use Minizip NG", default = false, type = "boolean"})
    add_configs("wide", {description = "Also build UTF-16 library (libxlsxio_readw)", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        if package:config("libzip") then
            package:add("deps", "libzip")
        elseif package:config("minizip_ng") then
            package:add("deps", "minizip-ng", {configs = {zlib = true}})
        else
            package:add("deps", "minizip")
        end

        if package:config("wide") then
            package:add("deps", "expat", {configs = {char_type = "wchar_t"}})
        else
            package:add("deps", "expat")
        end
    end)

    on_install("windows", "linux", "macosx", "mingw", "cross", function (package)
        local configs = {}
        if package:config("libzip") then
            configs.libzip = true
        elseif package:config("minizip_ng") then
            configs.minizip_ng = true
        end
        if package:config("wide") then
            package:add("defines", "XML_UNICODE")
            configs.wide = true
        end
        package:add("defines", "BUILD_XLSXIO_" .. (package:config("shared") and "SHARED" or "STATIC"))

        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("xlsxioread_open", {includes = "xlsxio_read.h"}))
    end)
