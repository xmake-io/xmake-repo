package("theora")
    set_homepage("https://theora.org/")
    set_description("Reference implementation of the Theora video compression format.")
    set_license("BSD-3-Clause")

    add_urls("https://gitlab.xiph.org/xiph/theora.git",
             "https://gitlab.xiph.org/xiph/theora/-/archive/v$(version)/theora-v$(version).tar.gz",
             "https://github.com/xiph/theora.git")

    add_versions("1.0", "bfaaa9dc04b57b44a3152c2132372c72a20d69e5fc6c9cc8f651cc1bc2434006")
    add_versions("1.1.0", "726e6e157f711011f7377773ce5ee233f7b73a425bf4ad192e4f8a8a71cf21d6")
    add_versions("1.1.1", "316ab9438310cf65c38aa7f5e25986b9d27e9aec771668260c733817ecf26dff")

    add_deps("libogg")
    if is_plat("bsd", "linux", "macosx") then
        add_deps("autoconf", "automake", "libtool 2.4.7")
    elseif is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    on_install("@bsd", "@linux", "@macosx", "wasm", function (package)
        local configs = {"--disable-oggtest", "--disable-vorbistest", "--disable-sdltest", "--disable-examples"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:is_plat("wasm") then
            table.insert(configs, "--disable-asm")
        end
        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("theora_encode_init", {includes = "theora/theora.h"}))
    end)
