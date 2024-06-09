package("mjson")

    set_homepage("https://github.com/cesanta/mjson")
    set_description("C/C++ JSON parser, emitter, JSON-RPC engine for embedded systems")
    set_license("MIT")

    add_urls("https://github.com/cesanta/mjson/archive/refs/tags/$(version).zip",
             "https://github.com/cesanta/mjson.git")
    add_versions("1.2.7", "ab3dfb813c8944f4a8ef6b17b0c2255136937d9fb24ef000e75aedd1fd17248d")
    add_versions("1.2.6", "d801348c38c883802a540eec0b3ea14318837084cbdd32bd83041d03a8850fe6")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    on_install(function (package)
        os.cd("src")
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("mjson")
                set_kind("static")
                add_files("mjson.c")
                add_headerfiles("mjson.h")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mjson_find", {includes = "mjson.h"}))
    end)
