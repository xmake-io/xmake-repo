package("xxhash")

    set_homepage("http://cyan4973.github.io/xxHash/")
    set_description("xxHash is an extremely fast non-cryptographic hash algorithm, working at RAM speed limit.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/Cyan4973/xxHash/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Cyan4973/xxHash.git")
    add_versions("v0.8.1", "3bb6b7d6f30c591dd65aaaff1c8b7a5b94d81687998ca9400082c739a690436c")
    add_versions("v0.8.0", "7054c3ebd169c97b64a92d7b994ab63c70dd53a06974f1f630ab782c28db0f4f")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("xxhash")
                set_kind("static")
                add_files("xxhash.c")
                add_headerfiles("xxhash.h", "xxh3.h")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("XXH_versionNumber", {includes = "xxhash.h"}))
    end)
