package("libaesgm")
    set_homepage("https://github.com/xmake-mirror/libaesgm")
    set_description("https://repology.org/project/libaesgm/packages")

    add_urls("https://github.com/xmake-mirror/libaesgm/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xmake-mirror/libaesgm.git")
    add_versions("2009.04.29", "9912e886c79d65e89612a5bf7d5198ee261eb6d6438af13ca5d0b668f93ba0ce")

    on_install("linux", function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("libaesgm")
                set_kind("$(kind)")
                add_files("aescrypt.c", "aestab.c", "aeskey.c")
                add_files("hmac.c", "sha2.c", "sha1.c", "pwd2key.c", "fileenc.c")
                add_headerfiles("*.h")
                add_defines("USE_SHA256")
        ]])
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("aes_init", {includes = "aes.h"}))
    end)
