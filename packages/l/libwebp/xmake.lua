package("libwebp")

    set_homepage("https://chromium.googlesource.com/webm/libwebp/")
    set_description("Library to encode and decode images in WebP format.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/webmproject/libwebp/archive/$(version).tar.gz",
             "https://github.com/webmproject/libwebp.git")
    add_versions("v1.1.0", "424faab60a14cb92c2a062733b6977b4cc1e875a6398887c5911b3a1a6c56c51")
    add_versions("v1.2.0", "d37571723f531e5002667632c94fa18857ed7eb5b0561e3b49e913c3e0b1403e")
    add_versions("v1.2.1", "7926985218c9e546069c2013dd93774aac3f012fd275247f82b0c119ec9a3801")
    add_versions("v1.2.2", "51e9297aadb7d9eb99129fe0050f53a11fcce38a0848fb2b0389e385ad93695e")
    add_versions("v1.3.0", "dc9860d3fe06013266c237959e1416b71c63b36f343aae1d65ea9c94832630e1")

    add_configs("anim_utils", {description = "Build animation utilities.", default = true, type = "boolean"})
    add_configs("cwebp",      {description = "Build the cwebp command line tool.", default = true, type = "boolean"})
    add_configs("dwebp",      {description = "Build the dwebp command line tool.", default = true, type = "boolean"})
    add_configs("gif2webp",   {description = "Build the gif2webp conversion tool.", default = true, type = "boolean"})
    add_configs("img2webp",   {description = "Build the img2webp animation tool.", default = true, type = "boolean"})
    add_configs("vwebp",      {description = "Build the vwebp viewer tool.", default = true, type = "boolean"})
    add_configs("webpinfo",   {description = "Build the webpinfo command line tool.", default = true, type = "boolean"})
    add_configs("libwebpmux", {description = "Build the libwebpmux library.", default = true, type = "boolean"})
    add_configs("webpmux",    {description = "Build the webpmux command line tool.", default = true, type = "boolean"})
    add_configs("extras",     {description = "Build extras.", default = true, type = "boolean"})
    add_configs("use_thread", {description = "Enable threading support.", default = true, type = "boolean"})

    add_deps("cmake")

    if is_plat("macosx") then
        add_extsources("brew::webp")
    elseif is_plat("linux") then
        add_extsources("apt::libwebp-dev", "pacman::libwebp")
    end

    on_load(function (package)
        if package:configs("use_thread") then
            add_defines("WEBP_USE_THREAD")
            if is_plat("linux", "bsd") then
                add_syslinks("pthread")
            end
        end
    end)

    on_install("linux", "macosx", "windows", "mingw", "bsd", "wasm", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") and name != "use_thread" then
                table.insert(configs, "-DWEBP_BUILD_" .. name:upper() .. "=" .. (enabled and "ON" or "OFF"))
            end
        end
        local cxflags
        if package:is_plat("windows") and package:config("shared") then
            cxflags = "-DWEBP_EXTERN=__declspec(dllexport)"
        end
        import("package.tools.cmake").install(package, configs, {cxflags = cxflags})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("WebPGetEncoderVersion", {includes = "webp/encode.h"}))
    end)
