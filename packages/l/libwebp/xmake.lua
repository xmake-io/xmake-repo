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
    add_versions("v1.2.3", "5e8452bcfe64badadbed5480ea9e86f156fe649f15e765e6059645f0aff73546")
    add_versions("v1.2.4", "dfe7bff3390cd4958da11e760b65318f0a48c32913e4d5bc5e8d55abaaa2d32e")
    add_versions("v1.3.0", "dc9860d3fe06013266c237959e1416b71c63b36f343aae1d65ea9c94832630e1")

    add_configs("anim_utils", {description = "Build animation utilities.", default = false, type = "boolean"})
    add_configs("cwebp",      {description = "Build the cwebp command line tool.", default = false, type = "boolean"})
    add_configs("dwebp",      {description = "Build the dwebp command line tool.", default = false, type = "boolean"})
    add_configs("gif2webp",   {description = "Build the gif2webp conversion tool.", default = false, type = "boolean"})
    add_configs("img2webp",   {description = "Build the img2webp animation tool.", default = false, type = "boolean"})
    add_configs("vwebp",      {description = "Build the vwebp viewer tool.", default = false, type = "boolean"})
    add_configs("webpinfo",   {description = "Build the webpinfo command line tool.", default = false, type = "boolean"})
    add_configs("libwebpmux", {description = "Build the libwebpmux library.", default = false, type = "boolean"})
    add_configs("webpmux",    {description = "Build the webpmux command line tool.", default = false, type = "boolean"})
    add_configs("sharpyuv",   {description = "Build the sharpyuv library, remove since v1.2.3", default = false, type = "boolean"})
    add_configs("extras",     {description = "Build extras.", default = false, type = "boolean"})
    add_configs("thread",     {description = "Enable threading support.", default = true, type = "boolean"})

    add_deps("cmake")

    if is_plat("macosx") then
        add_extsources("brew::webp")
    elseif is_plat("linux") then
        add_extsources("apt::libwebp-dev", "pacman::libwebp")
    end

    on_install("linux", "macosx", "windows", "mingw", "bsd", "wasm", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:version():ge("1.2.3") then
            package:config_set("sharpyuv", true)
        end
        for name, enabled in pairs(package:configs()) do
            if name == "thread" then
                if enabled then
                    package:add("defines", "WEBP_USE_THREAD")
                    if package:is_plat("linux", "bsd") then
                        package:add("syslinks", "pthread")
                    end
                end
            elseif not package:extraconf("configs", name, "builtin") then
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
